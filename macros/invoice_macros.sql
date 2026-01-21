{% macro get_source_id_key(prefix, id_column) %}
    -- Generates keys like 'R1001' (Rights) or 'T1001' (Technical)
    -- Handles NULLs by defaulting to -1
    CONCAT(
        '{{ prefix }}', 
        CAST(COALESCE({{ id_column }}, -1) AS VARCHAR)
    )
{% endmacro %}

{% macro get_hash_dim_invoice() %}
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
{% endmacro %}