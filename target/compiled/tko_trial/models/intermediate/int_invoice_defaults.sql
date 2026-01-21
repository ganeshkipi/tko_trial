

-- 1. Rights Dummy Row (R-1)
SELECT 
    
    -- Generates keys like 'R1001' (Rights) or 'T1001' (Technical)
    -- Handles NULLs by defaulting to -1
    CONCAT(
        'R', 
        CAST(COALESCE(-1, -1) AS VARCHAR)
    )
 AS InvoiceKey, -- Generates 'R-1'
    -1 AS SOLItem,
    'N/A' AS BillingCode,
    'N/A' AS InvoiceCategory,
    'N/A' AS InvoiceStatus,
    'N/A' AS InterfaceStatus,
    'N/A' AS FeeType,
    -1 AS OrderHeaderId,
    -1 AS OrderDetailId,
    -1 AS InstallmentNo,
    'N/A' AS CurrencyCode,
    1900 AS ProjectionYear,
    'N/A' AS SAPLineItemNumber,
    'N/A' AS SAPSalesOrderNumber,
    NULL::DATE AS InvoiceDueDate,
    NULL::DATE AS SAPInvoiceCreatedDate,
    NULL::DATE AS SAPDocumentDate,
    NULL::DATE AS InvoiceUpdatedDate,
    'Unknown' AS InvoiceInstructions,
    'Unknown' AS InvoiceDescription,
    'N/A' AS InvoiceReferenceNumber,
    'Rights' AS RightsTechIndicator,
    'N/A' AS CancellationStatus,
    'N/A' AS Address1,
    'N/A' AS Address2,
    'N/A' AS PostalCode,
    'N/A' AS City,
    'N/A' AS Region,
    'N/A' AS Country,
    'N/A' AS AccountingDocumentNumber,
    'N/A' AS ClearingDocumentNumber,
    NULL::DATE AS ClearingDocumentDate,
    'N/A' AS SOLNumber,
    'N/A' AS SAP_BILLING_STATUS,
    'N/A' AS IsDataMartDueDate,
    'N/A' AS IssueSite,
    -1 AS BillingCompanyId,
    'Unknown' AS BillingCompany,
    'N/A' AS CompanyCode,
    NULL::DATE AS InvoiceProcessedDate,
    'N/A' AS BillingType,
    NULL::DECIMAL(10,2) AS VAT,
    NULL::DECIMAL(10,2) AS WHT

UNION ALL

-- 2. Technical Dummy Row (T-1)
SELECT 
    
    -- Generates keys like 'R1001' (Rights) or 'T1001' (Technical)
    -- Handles NULLs by defaulting to -1
    CONCAT(
        'T', 
        CAST(COALESCE(-1, -1) AS VARCHAR)
    )
 AS InvoiceKey, -- Generates 'T-1'
    -1 AS SOLItem,
    'N/A' AS BillingCode,
    'N/A' AS InvoiceCategory,
    'N/A' AS InvoiceStatus,
    'N/A' AS InterfaceStatus,
    'N/A' AS FeeType,
    -1 AS OrderHeaderId,
    -1 AS OrderDetailId,
    -1 AS InstallmentNo,
    'N/A' AS CurrencyCode,
    1900 AS ProjectionYear,
    'N/A' AS SAPLineItemNumber,
    'N/A' AS SAPSalesOrderNumber,
    '1900-01-01'::DATE AS InvoiceDueDate,
    '1900-01-01'::DATE AS SAPInvoiceCreatedDate,
    '1900-01-01'::DATE AS SAPDocumentDate,
    '1900-01-01'::DATE AS InvoiceUpdatedDate,
    'Unknown' AS InvoiceInstructions,
    'Unknown' AS InvoiceDescription,
    'N/A' AS InvoiceReferenceNumber,
    'Technical' AS RightsTechIndicator,
    'N/A' AS CancellationStatus,
    'N/A' AS Address1,
    'N/A' AS Address2,
    'N/A' AS PostalCode,
    'N/A' AS City,
    'N/A' AS Region,
    'N/A' AS Country,
    'N/A' AS AccountingDocumentNumber,
    'N/A' AS ClearingDocumentNumber,
    '1900-01-01'::DATE AS ClearingDocumentDate,
    'N/A' AS SOLNumber,
    'N/A' AS SAP_BILLING_STATUS,
    'N/A' AS IsDataMartDueDate,
    'N/A' AS IssueSite,
    -1 AS BillingCompanyId,
    'Unknown' AS BillingCompany,
    'N/A' AS CompanyCode,
    NULL::DATE AS InvoiceProcessedDate,
    'N/A' AS BillingType,
    NULL::DECIMAL(10,2) AS VAT,
    NULL::DECIMAL(10,2) AS WHT

UNION ALL

-- 3. Generic Dummy Row (-1)
SELECT 
    
    -- Generates keys like 'R1001' (Rights) or 'T1001' (Technical)
    -- Handles NULLs by defaulting to -1
    CONCAT(
        '', 
        CAST(COALESCE(-1, -1) AS VARCHAR)
    )
 AS InvoiceKey, -- Generates '-1'
    -1 AS SOLItem,
    'N/A' AS BillingCode,
    'N/A' AS InvoiceCategory,
    'N/A' AS InvoiceStatus,
    'N/A' AS InterfaceStatus,
    'N/A' AS FeeType,
    -1 AS OrderHeaderId,
    -1 AS OrderDetailId,
    -1 AS InstallmentNo,
    'N/A' AS CurrencyCode,
    1900 AS ProjectionYear,
    'N/A' AS SAPLineItemNumber,
    'N/A' AS SAPSalesOrderNumber,
    NULL::DATE AS InvoiceDueDate,
    NULL::DATE AS SAPInvoiceCreatedDate,
    NULL::DATE AS SAPDocumentDate,
    NULL::DATE AS InvoiceUpdatedDate,
    'Unknown' AS InvoiceInstructions,
    'Unknown' AS InvoiceDescription,
    'N/A' AS InvoiceReferenceNumber,
    'Rights' AS RightsTechIndicator,
    'N/A' AS CancellationStatus,
    'N/A' AS Address1,
    'N/A' AS Address2,
    'N/A' AS PostalCode,
    'N/A' AS City,
    'N/A' AS Region,
    'N/A' AS Country,
    'N/A' AS AccountingDocumentNumber,
    'N/A' AS ClearingDocumentNumber,
    NULL::DATE AS ClearingDocumentDate,
    'N/A' AS SOLNumber,
    'N/A' AS SAP_BILLING_STATUS,
    'N/A' AS IsDataMartDueDate,
    'N/A' AS IssueSite,
    -1 AS BillingCompanyId,
    'Unknown' AS BillingCompany,
    'N/A' AS CompanyCode,
    NULL::DATE AS InvoiceProcessedDate,
    'N/A' AS BillingType,
    NULL::DECIMAL(10,2) AS VAT,
    NULL::DECIMAL(10,2) AS WHT