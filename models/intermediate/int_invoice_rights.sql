{{ config(materialized='view') }}

WITH rights_source AS (
    SELECT 
        r.Id AS RecordId,
        r.OrderRightsInvoiceId,
        r.OrderDetailId,
        r.VatCodeId,
        r.WithHoldingTaxRecordId,
        r.PseudoInvoicingTypeId,
        r.ProjectionYear,
        r.SAPLineItemNumber,
        r.LicensorId
    FROM {{ source('media_dm_staging', 'OrderRightsInvoiceOrderDetail') }} r
),
sap_data AS (
    SELECT * FROM {{ ref('int_sap_invoices_deduped') }}
    WHERE InvoiceType = 'R' OR InvoiceType IS NULL
)

SELECT
    -- 1. InvoiceKey
    {{ get_source_id_key('R', 'r.RecordId') }} as InvoiceKey,
    -- 2. SOLItem
    COALESCE(r.RecordId, -1) AS SOLItem,
    -- 3. BillingCode
    'Unknown' AS BillingCode,
    -- 4. InvoiceCategory
    'N/A' AS InvoiceCategory,
    -- 5. InvoiceStatus
    COALESCE(s.Description, 'N/A') AS InvoiceStatus,
    -- 6. InterfaceStatus
    'N/A' AS InterfaceStatus,
    -- 7. FeeType
    COALESCE(f.Description, 'N/A') AS FeeType,
    -- 8. OrderHeaderId
    COALESCE(ri.OrderHeaderId, -1) AS OrderHeaderId,
    -- 9. OrderDetailId
    COALESCE(r.OrderDetailId, -1) AS OrderDetailId,
    -- 10. InstallmentNo
    COALESCE(ri.InstallmentNo, -1) AS InstallmentNo,
    -- 11. CurrencyCode
    COALESCE(c.Code, 'N/A') AS CurrencyCode,
    -- 12. ProjectionYear
    COALESCE(CAST(r.ProjectionYear AS INT), 1900) AS ProjectionYear,
    -- 13. SAPLineItemNumber
    COALESCE(r.SAPLineItemNumber, 'N/A') AS SAPLineItemNumber,
    -- 14. SAPSalesOrderNumber
    COALESCE(ri.SAPSalesOrderNumber, 'N/A') AS SAPSalesOrderNumber,
    -- 15. InvoiceDueDate
    CAST(ri.InvoiceDueDate AS DATE) as InvoiceDueDate,
    -- 16. SAPInvoiceCreatedDate
    CAST(sii.SAP_INV_DATE_FIRST AS DATE) AS SAPInvoiceCreatedDate,
    -- 17. SAPDocumentDate
    CAST(ri.CreatedDate AS DATE) AS SAPDocumentDate,
    -- 18. InvoiceUpdatedDate
    CAST(ri.UpdatedDate AS DATE) AS InvoiceUpdatedDate,
    -- 19. InvoiceInstructions
    COALESCE(ri.InvoiceInstructions, 'Unknown') AS InvoiceInstructions,
    -- 20. InvoiceDescription
    COALESCE(ri.InvoiceDescription, 'Unknown') AS InvoiceDescription,
    -- 21. InvoiceReferenceNumber
    COALESCE(ri.InvoiceReferenceNumber, 'N/A') AS InvoiceReferenceNumber,
    -- 22. RightsTechIndicator
    'Rights' AS RightsTechIndicator,
    -- 23. CancellationStatus
    CASE 
        WHEN ri.CreditedInvoiceId IS NOT NULL THEN 'Credit Note' 
        WHEN ri.InvoiceWasCancelled = 1 THEN 'Cancelled' 
        ELSE 'Not Cancelled'
    END as CancellationStatus,
    -- 24. Address1
    COALESCE(ca.Line1, 'N/A') AS Address1,
    -- 25. Address2
    COALESCE(ca.Line2, 'N/A') AS Address2,
    -- 26. PostalCode
    COALESCE(ca.Line6, 'N/A') AS PostalCode,
    -- 27. City
    COALESCE(ca.Line3, 'N/A') AS City,
    -- 28. Region
    COALESCE(tr.Description, 'N/A') AS Region,
    -- 29. Country
    COALESCE(ti.Description, 'N/A') AS Country,
    -- 30. AccountingDocumentNumber
    COALESCE(sii.SAP_ACCTG_DOC, 'N/A') AS AccountingDocumentNumber,
    -- 31. ClearingDocumentNumber
    COALESCE(ri.SAPDocumentNumber, sii.SAP_CLEAR_DOC, 'N/A') AS ClearingDocumentNumber,
    -- 32. ClearingDocumentDate
    CAST(COALESCE(ri.ClearingDate, sii.SAP_CLEAR_DATE, '1900-01-01') AS DATE) AS ClearingDocumentDate,
    -- 33. SOLNumber
    COALESCE(sii.SOL_NUMBER, 'N/A') AS SOLNumber,
    -- 34. SAP_BILLING_STATUS
    COALESCE(sii.SAP_BILLING_STATUS, 'N/A') AS SAP_BILLING_STATUS,
    -- 35. IsDataMartDueDate
    CASE 
        WHEN ri.IsDataMartDueDate = 1 THEN 'Yes'
        ELSE 'No'
    END AS IsDataMartDueDate,
    -- 36. IssueSite
    COALESCE(isl.Description,'N/A') AS IssueSite,
    -- 37. BillingCompanyId
    COALESCE(bc.Id,-1) AS BillingCompanyId,
    -- 38. BillingCompany
    COALESCE(bc.Description,'Unknown') AS BillingCompany,
    -- 39. CompanyCode
    bc.SAPCompanyCode AS CompanyCode,
    -- 40. InvoiceProcessedDate
    CAST(ri.InvoiceProcessedDate AS DATE) AS InvoiceProcessedDate,
    -- 41. BillingType
    CASE
        WHEN oh.SalesCategoryId = 10 THEN 'Commission Billing' 
        WHEN r.LicensorId IN (10, 9) THEN 'IMG Billing'
        WHEN r.LicensorId IN (8, 7) THEN
            CASE 
                WHEN pit.Id IS NOT NULL THEN pit.Description || ' Billing'  
                ELSE 'Agency Billing'
            END
        ELSE '-'
    END AS BillingType,
    -- 42. VAT
    vc.SapVatRate/100 AS VAT,
    -- 43. WHT
    wht.TaxPercentage/100 AS WHT

FROM rights_source r
JOIN {{ source('media_dm_staging', 'OrderRightsInvoice') }} ri ON ri.Id = r.OrderRightsInvoiceId
LEFT JOIN {{ source('media_dm_staging', 'InvoiceStatus_lu') }} s ON s.Id = ri.InvoiceStatusId
LEFT JOIN {{ source('media_dm_staging', 'Fee_lu') }} f ON f.Id = ri.RightsFeeId
LEFT JOIN {{ source('media_dm_staging', 'Currency_lu') }} c ON c.Id = ri.CurrencyId
LEFT JOIN {{ source('media_dm_staging', 'CustomerAddress') }} ca ON ri.CustomerAddressId = ca.Id
LEFT JOIN {{ source('media_dm_staging', 'TerritoryRegion_lu') }} tr ON ca.TerritoryRegionId = tr.Id
LEFT JOIN {{ source('media_dm_staging', 'Territory_lu') }} ti ON ca.TerritoryId = ti.Id
INNER JOIN {{ source('media_dm_staging', 'OrderDetail') }} od ON r.OrderDetailId = od.Id
LEFT JOIN {{ source('media_dm_staging', 'BillingCompany_lu') }} bc ON bc.Id = od.BillingCompanyId
LEFT JOIN {{ source('media_dm_staging', 'IssueSite_lu') }} isl ON isl.Id = bc.IssueSiteId
LEFT JOIN {{ source('media_dm_staging', 'VatCodes') }} vc ON vc.Id = r.VatCodeId
LEFT JOIN {{ source('media_dm_staging', 'WithholdingTaxRecord') }} wht ON wht.Id = r.WithHoldingTaxRecordId
INNER JOIN {{ source('media_dm_staging', 'OrderHeader') }} oh ON oh.Id = ri.OrderHeaderId
LEFT JOIN {{ source('media_dm_staging', 'PseudoInvoicingType_lu') }} pit ON pit.Id = r.PseudoInvoicingTypeId
LEFT JOIN sap_data sii ON r.RecordId = sii.InvoiceId AND ri.InvoiceReferenceNumber = sii.SAP_INVOICE