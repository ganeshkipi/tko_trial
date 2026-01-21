
  create or replace   view MEDIADMSTAGING.intermediate.int_invoice_technical
  
  
  
  
  as (
    

WITH tech_source AS (
    SELECT 
        r.Id AS RecordId,
        r.OrderInvoiceId,
        r.ID,
        r.VatCodeId,
        r.WithHoldingTaxRecordId,
        r.PseudoInvoicingTypeId,
        r.ProjectionYear,
        r.LicensorId
    FROM MediaDMStaging.dbo.OrderInvoiceDetail r
),
sap_data AS (
    SELECT * FROM MEDIADMSTAGING.intermediate.int_sap_invoices_deduped
    WHERE InvoiceType = 'T' OR InvoiceType IS NULL
)

SELECT
    -- 1. InvoiceKey
    
    -- Generates keys like 'R1001' (Rights) or 'T1001' (Technical)
    -- Handles NULLs by defaulting to -1
    CONCAT(
        'T', 
        CAST(COALESCE(r.RecordId, -1) AS VARCHAR)
    )
 as InvoiceKey,
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
    COALESCE(r.ID, -1) AS OrderDetailId,
    -- 10. InstallmentNo
    COALESCE(ri.InstallmentNo, -1) AS InstallmentNo,
    -- 11. CurrencyCode
    COALESCE(c.Code, 'N/A') AS CurrencyCode,
    -- 12. ProjectionYear
    COALESCE(CAST(r.ProjectionYear AS INT), 1900) AS ProjectionYear,
    -- 13. SAPLineItemNumber
    'N/A' AS SAPLineItemNumber,
    -- 14. SAPSalesOrderNumber
    COALESCE(ri.SAPSalesOrderNumber, 'N/A') AS SAPSalesOrderNumber,
    -- 15. InvoiceDueDate
    CAST(ri.InvoiceDueDate AS DATE) AS InvoiceDueDate,
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
    'Technical' AS RightsTechIndicator,
    -- 23. CancellationStatus
    CASE 
        WHEN ri.CreditedInvoiceId IS NOT NULL THEN 'Credit Note' 
        WHEN ri.InvoiceWasCancelled = 1 THEN 'Cancelled' 
        ELSE 'Not Cancelled'
    END AS CancellationStatus,
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
    CAST(COALESCE(ri.ClearingDate, sii.SAP_CLEAR_DATE) AS DATE) AS ClearingDocumentDate,
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

FROM tech_source r
JOIN MediaDMStaging.dbo.OrderInvoice ri ON ri.Id = r.OrderInvoiceId
LEFT JOIN MediaDMStaging.dbo.InvoiceStatus_lu s ON s.Id = ri.InvoiceStatusId
LEFT JOIN MediaDMStaging.dbo.Fee_lu f ON f.Id = ri.FeeId
LEFT JOIN MediaDMStaging.dbo.Currency_lu c ON c.Id = ri.CurrencyId
LEFT JOIN MediaDMStaging.dbo.CustomerAddress ca ON ri.CustomerAddressId = ca.Id
LEFT JOIN MediaDMStaging.dbo.TerritoryRegion_lu tr ON ca.TerritoryRegionId = tr.Id
LEFT JOIN MediaDMStaging.dbo.Territory_lu ti ON ca.TerritoryId = ti.Id
INNER JOIN MediaDMStaging.dbo.OrderDetail od ON r.ID = od.Id
LEFT JOIN MediaDMStaging.dbo.BillingCompany_lu bc ON bc.Id = od.BillingCompanyId
LEFT JOIN MediaDMStaging.dbo.IssueSite_lu isl ON isl.Id = bc.IssueSiteId
LEFT JOIN MediaDMStaging.dbo.VatCodes vc ON vc.Id = r.VatCodeId
LEFT JOIN MediaDMStaging.dbo.WithholdingTaxRecord wht ON wht.Id = r.WithHoldingTaxRecordId
INNER JOIN MediaDMStaging.dbo.OrderHeader oh ON oh.Id = ri.OrderHeaderId
LEFT JOIN MediaDMStaging.dbo.PseudoInvoicingType_lu pit ON pit.Id = r.PseudoInvoicingTypeId
LEFT JOIN sap_data sii ON r.RecordId = sii.InvoiceId AND ri.InvoiceReferenceNumber = sii.SAP_INVOICE
  );

