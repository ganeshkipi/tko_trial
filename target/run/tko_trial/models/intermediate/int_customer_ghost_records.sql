
  create or replace   view MEDIADMSTAGING.intermediate.int_customer_ghost_records
  
  
  
  
  as (
    

WITH customer_audit AS (
    SELECT * FROM MediaDMStaging.dbo.Customer_aud
),
active_customers AS (
    SELECT Id FROM MediaDMStaging.dbo.Customer
),
ranked_ghosts AS (
    SELECT
        ca.*,
        ROW_NUMBER() OVER(PARTITION BY ca.Id ORDER BY ca.AuditId DESC) as rn
    FROM customer_audit ca
    LEFT JOIN active_customers c ON ca.Id = c.Id
    WHERE c.Id IS NULL
)
SELECT
    Id as CustomerId,
    COALESCE(CustomerNo, -1) as CustomerNo,
    CustomerFullName || ' - Is not exist in source app anymore' as CustomerFullName,
    ShortName || ' - removed' as ShortName,
    ProjectionTerritoryId,
    RightsSelectionId,
    TerritorySelectionId,
    LanguageSelectionId,
    NumberOfTransmissions,
    GeneralTypeLiveId,
    GeneralTypeProducedId,
    DeliveryFormatId,
    FormatTypeId,
    DeliveryMethodId,
    DetailComment,
    CustomerType2Id,
    AudioConfig,
    BlockedDate,
    StandardId,
    CreatedDate,
    CreatedBy
FROM ranked_ghosts
WHERE rn = 1
  );

