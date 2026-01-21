{{ config(materialized='view') }}

WITH raw_history AS (
    -- 1. Current State (The latest view of the customer)
    SELECT 
        Id, 
        BlockedDate, 
        COALESCE(UpdatedBy, CreatedBy) as UpdatedBy, 
        COALESCE(UpdatedDate, CreatedDate) as AuditTimeStamp
    FROM {{ source('media_dm_staging', 'Customer') }}
    WHERE StatusId = 1

    UNION ALL

    -- 2. Historical State (From the audit table)
    SELECT 
        Id, 
        BlockedDate, 
        UpdatedBy, 
        AuditTimeStamp
    FROM {{ source('media_dm_staging', 'Customer_aud') }}
    WHERE StatusId = 1
),

calculated_history AS (
    SELECT 
        *,
        -- NOW the window function sees both Current and Historical rows
        LEAD(BlockedDate) OVER (PARTITION BY Id ORDER BY AuditTimeStamp DESC) as PreviousBlockedDate
    FROM raw_history
),

state_changes AS (
    SELECT
        *,
        ROW_NUMBER() OVER (PARTITION BY Id ORDER BY AuditTimeStamp ASC) as rn_asc,
        ROW_NUMBER() OVER (PARTITION BY Id ORDER BY AuditTimeStamp DESC) as rn_desc
    FROM calculated_history
    -- Logic: Current state is Unblocked (9999-12-31), but Previous state was Blocked (or NULL/Start of time)
    WHERE BlockedDate = '9999-12-31' 
      AND (PreviousBlockedDate < '9999-12-31' OR PreviousBlockedDate IS NULL)
)

SELECT
    Id as CustomerId,
    MAX(CASE WHEN rn_asc = 1 THEN AuditTimeStamp END) as FirstUnblockedDate,
    MAX(CASE WHEN rn_asc = 1 THEN UpdatedBy END) as FirstUnblockedBy,
    MAX(CASE WHEN rn_desc = 1 THEN AuditTimeStamp END) as UnblockedDate,
    MAX(CASE WHEN rn_desc = 1 THEN UpdatedBy END) as UnblockedBy
FROM state_changes
GROUP BY Id