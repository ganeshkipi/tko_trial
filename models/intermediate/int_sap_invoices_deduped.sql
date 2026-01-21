{{ config(materialized='view') }}

WITH raw_sap AS (
    SELECT 
        SOL_NUMBER,
        SAP_INVOICE,
        SAP_ACCTG_DOC,
        CASE WHEN SAP_CLEAR_DOC = '' THEN NULL ELSE SAP_CLEAR_DOC END AS SAP_CLEAR_DOC,
        TRY_CAST(SAP_CLEAR_DATE AS DATE) AS SAP_CLEAR_DATE,
        TRY_CAST(SAP_INV_DATE AS DATE) AS SAP_INV_DATE,
        InvoiceId,
        InvoiceType,
        LOWER(SAP_BILLING_STATUS) AS SAP_BILLING_STATUS,
        UpdatedDate,
        Id
    FROM {{ source('media_dm_staging', 'SAPImportedInvoices') }}
    WHERE StatusId = 1
),

calculated_windows AS (
    SELECT 
        *,
        FIRST_VALUE(TRY_CAST(SAP_INV_DATE AS DATE)) OVER (
            PARTITION BY SAP_INVOICE, InvoiceId 
            ORDER BY UpdatedDate
        ) AS SAP_INV_DATE_FIRST,
        
        ROW_NUMBER() OVER (
            PARTITION BY InvoiceId, SAP_INVOICE 
            ORDER BY UpdatedDate DESC, Id DESC
        ) AS RowNumber
    FROM raw_sap
)

SELECT * FROM calculated_windows WHERE RowNumber = 1