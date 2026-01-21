WITH 
all_customers AS (
    SELECT 
        Id, CustomerNo, CustomerFullName, ShortName, ProjectionTerritoryId, RightsSelectionId, 
        TerritorySelectionId, LanguageSelectionId, NumberOfTransmissions, GeneralTypeLiveId, 
        GeneralTypeProducedId, DeliveryFormatId, FormatTypeId, DeliveryMethodId, DetailComment, 
        CustomerType2Id, AudioConfig, BlockedDate, StandardId, CreatedDate, CreatedBy 
    FROM {{ source('media_dm_staging', 'Customer') }}
    UNION ALL
    SELECT * FROM {{ ref('int_customer_ghost_records') }}
),
contexts AS (
    SELECT * FROM {{ ref('int_customer_contexts') }}
),
unblocking AS (
    SELECT * FROM {{ ref('int_customer_unblocking_history') }}
),
airlines AS (
    SELECT * FROM {{ ref('int_customer_airlines_agg') }}
),

joined_data AS (
    SELECT
        -- Use Macro for Key
        {{ get_customer_key('contexts.CustomerId', 'contexts.ContactId', 'contexts.CustomerAddressId') }} as CustomerKey,
        
        contexts.CustomerId as SourceCustomerId,
        contexts.ContactId as SourceContactId,
        contexts.CustomerAddressId as SourceCustomerAddressId,
        
        c.CustomerNo,
        c.CustomerFullName as CustomerName,
        c.ShortName as CustomerShortName,
        COALESCE(cc.ContactName, 'N/A') as ContactName,
        COALESCE(t.Description, 'N/A') as ProjectionTerritory,
        COALESCE(ca.SAPCustomerNumber, 'N/A') as SAPCustomerNumber,
        COALESCE(ca.PayerNumber, 'N/A') as SAPPayerNumber,
        c.Id as SOLId,
        COALESCE(rse.Description, 'N/A') as RightsSelection,
        COALESCE(tse.Description, 'N/A') as TerritorySelection,
        COALESCE(lse.Description, 'N/A') as LanguageSelection,
        COALESCE(c.NumberOfTransmissions, 0) as NumberOfTransmissions,
        
        -- Transmissions Logic
        CASE
            WHEN c.NumberOfTransmissions = -1 THEN 'Unlimited Transmissions'
            WHEN c.NumberOfTransmissions = -2 THEN 'No Set'
            WHEN c.NumberOfTransmissions = -3 THEN 'Holdback'
            WHEN c.NumberOfTransmissions = 2 THEN '2'
            WHEN c.NumberOfTransmissions = -4 THEN 'Values'
            WHEN c.NumberOfTransmissions = -5 THEN 'Dark Period'
            WHEN c.NumberOfTransmissions = -6 THEN 'Exclusive Option to Extend'
            WHEN c.NumberOfTransmissions IS NOT NULL THEN CAST(c.NumberOfTransmissions as VARCHAR)
            ELSE 'N/A'
        END as NumberOfTransmissionsName,
        
        COALESCE(gtl.Description, 'N/A') as GeneralTypeLive,
        COALESCE(gtp.Description, 'N/A') as GeneralTypeProduced,
        COALESCE(df.Description, 'N/A') as DeliveryFormat,
        COALESCE(tf.Description, 'N/A') as FrameRate,
        COALESCE(dm.Description, 'N/A') as DeliveryMethod,
        COALESCE(LEFT(c.DetailComment,1000), 'N/A') as Comment,
        COALESCE(ct2.Description, 'N/A') as CustomerType,
        COALESCE(c.AudioConfig, 'N/A') as AudioConfig,
        
        -- Status Logic
        CASE 
            WHEN c.BlockedDate = '9999-12-31' THEN 'Unblocked'
            WHEN c.BlockedDate > CURRENT_DATE() THEN 'Temporarily Unblocked'
            ELSE 'Blocked'
        END as CustomerState,
        
        COALESCE(vs.Description, 'N/A') as FrameResolution,
        
        -- Aggregated Strings
        COALESCE(al.CustomerAddressAirline, 'N/A') as CustomerAddressAirline,
        COALESCE(al.CustomerInFlightDefaultsCurrency, 'N/A') as CustomerInFlightDefaultsCurrency,
        COALESCE(al.CustomerInFlightDefaultsAirline, 'N/A') as CustomerInFlightDefaultsAirline,
        COALESCE(al.CustomerInFlightRightsAirline, 'N/A') as CustomerInFlightRightsAirline,
        COALESCE(al.CustomerContactAirline, 'N/A') as CustomerContactAirline,
        
        u.FirstUnblockedDate,
        COALESCE(fub.Firstname || ' ' || fub.Lastname, 'N/A') as FirstUnblockedBy,
        u.UnblockedDate,
        COALESCE(ub.Firstname || ' ' || ub.Lastname, 'N/A') as UnblockedBy,
        
        c.CreatedDate,
        COALESCE(cb.Firstname || ' ' || cb.Lastname, 'N/A') as CreatedBy

    FROM contexts
    INNER JOIN all_customers c ON contexts.CustomerId = c.Id
    LEFT JOIN unblocking u ON c.Id = u.CustomerId
    LEFT JOIN airlines al ON c.Id = al.CustomerId
    
    LEFT JOIN {{ source('media_dm_staging', 'CustomerContact') }} cc ON contexts.ContactId = cc.Id
    LEFT JOIN {{ source('media_dm_staging', 'CustomerAddress') }} ca ON contexts.CustomerAddressId = ca.Id
    LEFT JOIN {{ source('media_dm_staging', 'Territory_lu') }} t ON c.ProjectionTerritoryId = t.Id
    LEFT JOIN {{ source('media_dm_staging', 'RightsSelectionEx') }} rse ON c.RightsSelectionId = rse.Id
    LEFT JOIN {{ source('media_dm_staging', 'TerritorySelectionEx') }} tse ON c.TerritorySelectionId = tse.Id
    LEFT JOIN {{ source('media_dm_staging', 'LanguageSelectionEx') }} lse ON c.LanguageSelectionId = lse.Id
    LEFT JOIN {{ source('media_dm_staging', 'GeneralType_lu') }} gtl ON c.GeneralTypeLiveId = gtl.Id
    LEFT JOIN {{ source('media_dm_staging', 'GeneralType_lu') }} gtp ON c.GeneralTypeProducedId = gtp.Id
    LEFT JOIN {{ source('media_dm_staging', 'DeliveryFormat_lu') }} df ON c.DeliveryFormatId = df.Id
    LEFT JOIN {{ source('media_dm_staging', 'TapeFormat_lu') }} tf ON c.FormatTypeId = tf.Id
    LEFT JOIN {{ source('media_dm_staging', 'DeliveryMethod_lu') }} dm ON c.DeliveryMethodId = dm.Id
    LEFT JOIN {{ source('media_dm_staging', 'CustomerType2_lu') }} ct2 ON c.CustomerType2Id = ct2.Id
    LEFT JOIN {{ source('media_dm_staging', 'VideoStandard_lu') }} vs ON c.StandardId = vs.Id
    LEFT JOIN {{ source('media_dm_staging', 'User') }} fub ON u.FirstUnblockedBy = fub.Id
    LEFT JOIN {{ source('media_dm_staging', 'User') }} ub ON u.UnblockedBy = ub.Id
    LEFT JOIN {{ source('media_dm_staging', 'User') }} cb ON c.CreatedBy = cb.Id

    UNION ALL
    
    -- Default Dummy Row
    SELECT 
        {{ get_customer_key('-1', '-1', '-1') }} as CustomerKey,
        -1, -1, -1, -1, 'Unknown', 'Unknown', 'Unknown', 'Unknown', 'N/A', 'N/A', -1,
        'N/A', 'N/A', 'N/A', 0, 'N/A', 'N/A', 'N/A', 'N/A', 'N/A', 'N/A', 'N/A',
        'N/A', 'N/A', 'N/A', 'N/A', 'N/A', 'N/A', 'N/A', 'N/A', 'N/A',
        NULL, 'N/A', NULL, 'N/A', NULL, 'N/A'
)

SELECT 
    *,
    {{ get_customer_hash() }} as HashKey,
    NULL as DeletedOn
FROM joined_data