{{
    config(
        materialized='dynamic_table',
        schema='DEV',
        snowflake_warehouse='COMPUTE_WH',
        target_lag='1 hour',
        on_configuration_change='apply'
    )
}}

WITH combined_invoices AS (
    -- 1. Rights Invoices (Prefix 'R')
    SELECT * FROM {{ ref('int_invoice_rights') }}
    
    UNION ALL
    
    -- 2. Technical Invoices (Prefix 'T')
    SELECT * FROM {{ ref('int_invoice_technical') }}
    
    UNION ALL
    
    -- 3. Default/Dummy Rows (R-1, T-1, -1)
    SELECT * FROM {{ ref('int_invoice_defaults') }}
)

SELECT 
    InvoiceKey,
    SOLItem,
    BillingCode,
    InvoiceCategory,
    InvoiceStatus,
    InterfaceStatus,
    FeeType,
    OrderHeaderId,
    OrderDetailId,
    InstallmentNo,
    CurrencyCode,
    ProjectionYear,
    SAPLineItemNumber,
    SAPSalesOrderNumber,
    InvoiceDueDate,
    SAPInvoiceCreatedDate,
    SAPDocumentDate,
    InvoiceUpdatedDate,
    InvoiceInstructions,
    InvoiceDescription,
    InvoiceReferenceNumber,
    RightsTechIndicator,
    CancellationStatus,
    Address1,
    Address2,
    PostalCode,
    City,
    Region,
    Country,
    AccountingDocumentNumber,
    ClearingDocumentNumber,
    ClearingDocumentDate,
    SOLNumber,
    SAP_BILLING_STATUS,
    IsDataMartDueDate,
    IssueSite,
    BillingCompanyId,
    BillingCompany,
    CompanyCode,
    InvoiceProcessedDate,
    BillingType,
    VAT,
    WHT,
    
    -- Hash Key Generation using the macro
    {{ get_hash_dim_invoice() }} AS HashKey,
    
    NULL AS DeletedOn

FROM combined_invoices