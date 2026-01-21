{{ config(materialized='view') }}

SELECT
    C.Id as CustomerId,
    -- Address Airlines
    (SELECT LISTAGG(DISTINCT R.Description, ', ') WITHIN GROUP (ORDER BY R.Description)
     FROM {{ source('media_dm_staging', 'CustomerAddress') }} CA
     JOIN {{ source('media_dm_staging', 'CustomerAddressAirline') }} CAA ON CA.Id = CAA.CustomerAddressId
     JOIN {{ source('media_dm_staging', 'Rights_lu') }} R ON CAA.AirlineId = R.Id
     WHERE CA.CustomerId = C.Id
    ) as CustomerAddressAirline,
    
    -- In Flight Defaults Airline
    (SELECT LISTAGG(DISTINCT R.Description, ', ') WITHIN GROUP (ORDER BY R.Description)
     FROM {{ source('media_dm_staging', 'CustomerInFlightDefaults') }} cifd
     JOIN {{ source('media_dm_staging', 'CustomerInFlightDefaultsAirline') }} cifda ON cifd.Id = cifda.CustomerInFlightDefaultsId
     JOIN {{ source('media_dm_staging', 'Rights_lu') }} R ON R.Id = cifda.AirlineId
     WHERE cifd.CustomerId = C.Id
    ) as CustomerInFlightDefaultsAirline,

    -- In Flight Defaults Currency
    (SELECT LISTAGG(DISTINCT clu.Code, ', ') WITHIN GROUP (ORDER BY clu.Code)
     FROM {{ source('media_dm_staging', 'CustomerInFlightDefaults') }} cifd
     JOIN {{ source('media_dm_staging', 'CustomerInFlightDefaultsAirline') }} cifda ON cifd.Id = cifda.CustomerInFlightDefaultsId
     JOIN {{ source('media_dm_staging', 'Currency_lu') }} clu ON clu.Id = cifd.CurrencyId
     WHERE cifd.CustomerId = C.Id
    ) as CustomerInFlightDefaultsCurrency,

    -- In Flight Rights Airline
    (SELECT LISTAGG(DISTINCT R.Description, ', ') WITHIN GROUP (ORDER BY R.Description)
     FROM {{ source('media_dm_staging', 'CustomerInFlightRights') }} cifr
     JOIN {{ source('media_dm_staging', 'CustomerInFlightRightsAirline') }} cifra ON cifr.Id = cifra.CustomerInFlightRightsId
     JOIN {{ source('media_dm_staging', 'Rights_lu') }} R ON R.Id = cifra.AirlineId
     WHERE cifr.CustomerId = C.Id
    ) as CustomerInFlightRightsAirline,

    -- Contact Airlines
    (SELECT LISTAGG(DISTINCT R.Description, ', ') WITHIN GROUP (ORDER BY R.Description)
     FROM {{ source('media_dm_staging', 'CustomerContact') }} CC
     JOIN {{ source('media_dm_staging', 'CustomerContactAirline') }} CCA ON CC.Id = CCA.CustomerContactId
     JOIN {{ source('media_dm_staging', 'Rights_lu') }} R ON CCA.AirlineId = R.Id
     WHERE CC.CustomerId = C.Id
    ) as CustomerContactAirline

FROM {{ source('media_dm_staging', 'Customer') }} C