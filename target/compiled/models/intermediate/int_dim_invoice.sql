
WITH combined_invoices AS (
    -- 1. Rights Invoices (Prefix 'R')
    SELECT * FROM MEDIADMSTAGING.intermediate.int_invoice_rights
    
    UNION ALL
    
    -- 2. Technical Invoices (Prefix 'T')
    SELECT * FROM MEDIADMSTAGING.intermediate.int_invoice_technical
    
    UNION ALL
    
    -- 3. Default/Dummy Rows (R-1, T-1, -1)
    SELECT * FROM MEDIADMSTAGING.intermediate.int_invoice_defaults
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
    
    -- Concatenates all relevant dimension columns and hashes them to fingerprint the row
    -- Uses standard Snowflake MD5 and NULL handling
    MD5(
        CONCAT(
            COALESCE(CAST(InvoiceKey AS VARCHAR), ''), '|',
            COALESCE(CAST(SOLItem AS VARCHAR), ''), '|',
            COALESCE(CAST(BillingCode AS VARCHAR), ''), '|',
            COALESCE(CAST(InvoiceCategory AS VARCHAR), ''), '|',
            COALESCE(CAST(InvoiceStatus AS VARCHAR), ''), '|',
            COALESCE(CAST(InterfaceStatus AS VARCHAR), ''), '|',
            COALESCE(CAST(FeeType AS VARCHAR), ''), '|',
            COALESCE(CAST(OrderHeaderId AS VARCHAR), ''), '|',
            COALESCE(CAST(OrderDetailId AS VARCHAR), ''), '|',
            COALESCE(CAST(InstallmentNo AS VARCHAR), ''), '|',
            COALESCE(CAST(CurrencyCode AS VARCHAR), ''), '|',
            COALESCE(CAST(ProjectionYear AS VARCHAR), ''), '|',
            COALESCE(CAST(SAPLineItemNumber AS VARCHAR), ''), '|',
            COALESCE(CAST(SAPSalesOrderNumber AS VARCHAR), ''), '|',
            COALESCE(TO_CHAR(InvoiceDueDate, 'YYYY-MM-DD'), ''), '|',
            COALESCE(TO_CHAR(SAPInvoiceCreatedDate, 'YYYY-MM-DD'), ''), '|',
            COALESCE(TO_CHAR(SAPDocumentDate, 'YYYY-MM-DD'), ''), '|',
            COALESCE(TO_CHAR(InvoiceUpdatedDate, 'YYYY-MM-DD'), ''), '|',
            COALESCE(CAST(InvoiceInstructions AS VARCHAR), ''), '|',
            COALESCE(CAST(InvoiceDescription AS VARCHAR), ''), '|',
            COALESCE(CAST(InvoiceReferenceNumber AS VARCHAR), ''), '|',
            COALESCE(CAST(RightsTechIndicator AS VARCHAR), ''), '|',
            COALESCE(CAST(CancellationStatus AS VARCHAR), ''), '|',
            COALESCE(CAST(Address1 AS VARCHAR), ''), '|',
            COALESCE(CAST(Address2 AS VARCHAR), ''), '|',
            COALESCE(CAST(PostalCode AS VARCHAR), ''), '|',
            COALESCE(CAST(City AS VARCHAR), ''), '|',
            COALESCE(CAST(Region AS VARCHAR), ''), '|',
            COALESCE(CAST(Country AS VARCHAR), ''), '|',
            COALESCE(CAST(AccountingDocumentNumber AS VARCHAR), ''), '|',
            COALESCE(CAST(ClearingDocumentNumber AS VARCHAR), ''), '|',
            COALESCE(TO_CHAR(ClearingDocumentDate, 'YYYY-MM-DD'), ''), '|',
            COALESCE(CAST(SOLNumber AS VARCHAR), ''), '|',
            COALESCE(CAST(SAP_BILLING_STATUS AS VARCHAR), ''), '|',
            COALESCE(CAST(IsDataMartDueDate AS VARCHAR), ''), '|',
            COALESCE(CAST(IssueSite AS VARCHAR), ''), '|',
            COALESCE(CAST(BillingCompanyId AS VARCHAR), ''), '|',
            COALESCE(CAST(BillingCompany AS VARCHAR), ''), '|',
            COALESCE(CAST(CompanyCode AS VARCHAR), ''), '|',
            COALESCE(TO_CHAR(InvoiceProcessedDate, 'YYYY-MM-DD'), ''), '|',
            COALESCE(CAST(BillingType AS VARCHAR), ''), '|',
            COALESCE(CAST(VAT AS VARCHAR), ''), '|',
            COALESCE(CAST(WHT AS VARCHAR), '')
        )
    )
 AS HashKey,
    
    NULL AS DeletedOn

FROM combined_invoices