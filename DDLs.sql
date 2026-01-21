-- 1. Set Context
create or replace database MEDIADMSTAGING;
USE DATABASE MEDIADMSTAGING;
CREATE SCHEMA IF NOT EXISTS DBO;
USE SCHEMA DBO;

--***************************DIM INVOICE**************************************************************

-- 2. Create Tables
CREATE OR REPLACE TABLE SAPImportedInvoices (
    Id INT, SOL_NUMBER VARCHAR(50), SAP_INVOICE VARCHAR(50), SAP_ACCTG_DOC VARCHAR(50),
    SAP_CLEAR_DOC VARCHAR(50), SAP_CLEAR_DATE VARCHAR(20), SAP_INV_DATE VARCHAR(20),
    UpdatedDate TIMESTAMP, InvoiceId INT, InvoiceType VARCHAR(10), SAP_BILLING_STATUS VARCHAR(50), StatusId INT
);

CREATE OR REPLACE TABLE OrderRightsInvoice (
    Id INT, OrderHeaderId INT, InvoiceStatusId INT, RightsFeeId INT, CurrencyId INT,
    CustomerAddressId INT, InstallmentNo INT, SAPSalesOrderNumber VARCHAR(50),
    InvoiceDueDate DATE, CreatedDate TIMESTAMP, UpdatedDate TIMESTAMP,
    InvoiceInstructions VARCHAR(255), InvoiceDescription VARCHAR(255),
    InvoiceReferenceNumber VARCHAR(50), CreditedInvoiceId INT, InvoiceWasCancelled INT,
    SAPDocumentNumber VARCHAR(50), ClearingDate DATE, IsDataMartDueDate INT,
    InvoiceProcessedDate TIMESTAMP
);

CREATE OR REPLACE TABLE OrderRightsInvoiceOrderDetail (
    Id INT, OrderRightsInvoiceId INT, OrderDetailId INT, VatCodeId INT,
    WithHoldingTaxRecordId INT, PseudoInvoicingTypeId INT, ProjectionYear INT,
    SAPLineItemNumber VARCHAR(20), LicensorId INT
);

CREATE OR REPLACE TABLE OrderInvoice ( -- Technical Invoice
    Id INT, OrderHeaderId INT, InvoiceStatusId INT, FeeId INT, CurrencyId INT,
    CustomerAddressId INT, InstallmentNo INT, SAPSalesOrderNumber VARCHAR(50),
    InvoiceDueDate DATE, CreatedDate TIMESTAMP, UpdatedDate TIMESTAMP,
    InvoiceInstructions VARCHAR(255), InvoiceDescription VARCHAR(255),
    InvoiceReferenceNumber VARCHAR(50), CreditedInvoiceId INT, InvoiceWasCancelled INT,
    SAPDocumentNumber VARCHAR(50), ClearingDate DATE, IsDataMartDueDate INT,
    InvoiceProcessedDate TIMESTAMP
);

CREATE OR REPLACE TABLE OrderInvoiceDetail ( -- Technical Detail
    Id INT, OrderInvoiceId INT, OrderDetailId INT, VatCodeId INT,
    WithHoldingTaxRecordId INT, PseudoInvoicingTypeId INT, ProjectionYear INT, LicensorId INT
);

CREATE OR REPLACE TABLE OrderHeader (Id INT, SalesCategoryId INT);
CREATE OR REPLACE TABLE OrderDetail (Id INT, BillingCompanyId INT);
CREATE OR REPLACE TABLE InvoiceStatus_lu (Id INT, Description VARCHAR(50));
CREATE OR REPLACE TABLE Fee_lu (Id INT, Description VARCHAR(50));
CREATE OR REPLACE TABLE Currency_lu (Id INT, Code VARCHAR(10));
CREATE OR REPLACE TABLE CustomerAddress (
    Id INT, TerritoryRegionId INT, TerritoryId INT, 
    Line1 VARCHAR(100), Line2 VARCHAR(100), Line3 VARCHAR(100), Line6 VARCHAR(20)
);
CREATE OR REPLACE TABLE TerritoryRegion_lu (Id INT, Description VARCHAR(50));
CREATE OR REPLACE TABLE Territory_lu (Id INT, Description VARCHAR(50));
CREATE OR REPLACE TABLE BillingCompany_lu (Id INT, IssueSiteId INT, Description VARCHAR(100), SAPCompanyCode VARCHAR(20));
CREATE OR REPLACE TABLE IssueSite_lu (Id INT, Description VARCHAR(50));
CREATE OR REPLACE TABLE VatCodes (Id INT, SapVatRate DECIMAL(10,2));
CREATE OR REPLACE TABLE WithholdingTaxRecord (Id INT, TaxPercentage DECIMAL(10,2));
CREATE OR REPLACE TABLE PseudoInvoicingType_lu (Id INT, Description VARCHAR(50));

-- 3. Populate Lookups (Static Data)
INSERT INTO InvoiceStatus_lu VALUES (1, 'Posted'), (2, 'Draft'), (3, 'Cancelled');
INSERT INTO Fee_lu VALUES (1, 'License Fee'), (2, 'Tech Fee'), (3, 'Admin Fee');
INSERT INTO Currency_lu VALUES (1, 'USD'), (2, 'EUR'), (3, 'GBP');
INSERT INTO TerritoryRegion_lu VALUES (1, 'North America'), (2, 'EMEA'), (3, 'APAC');
INSERT INTO Territory_lu VALUES (1, 'USA'), (2, 'UK'), (3, 'Germany'), (4, 'Japan');
INSERT INTO IssueSite_lu VALUES (1, 'New York'), (2, 'London');
INSERT INTO BillingCompany_lu VALUES (10, 1, 'IMG Media NY', 'COMP01'), (20, 2, 'IMG Media UK', 'COMP02');
INSERT INTO VatCodes VALUES (1, 20.00), (2, 0.00), (3, 5.00);
INSERT INTO WithholdingTaxRecord VALUES (1, 0.00), (2, 10.00);
INSERT INTO PseudoInvoicingType_lu VALUES (50, 'Self-Billing'), (51, 'Standard');
INSERT INTO CustomerAddress VALUES 
(100, 1, 1, '123 Main St', 'Suite 5', 'New York', '10001'),
(101, 2, 2, '10 Downing St', '', 'London', 'SW1A 2AA'),
(102, 3, 4, '1-1 Chiyoda', '', 'Tokyo', '100-0001');

-- 4. Generate 100 Rows of Transactional Data
-- We use a generator to create sequence numbers, then modulo arithmetic to randomize values.

-- A. OrderHeader & OrderDetail (100 rows)
INSERT INTO OrderHeader (Id, SalesCategoryId)
SELECT 
    seq4() + 500 AS Id,
    CASE WHEN seq4() % 5 = 0 THEN 10 ELSE 1 END AS SalesCategoryId -- 20% Commission Billing
FROM TABLE(GENERATOR(ROWCOUNT => 100));

INSERT INTO OrderDetail (Id, BillingCompanyId)
SELECT 
    seq4() + 1000 AS Id,
    CASE WHEN seq4() % 2 = 0 THEN 10 ELSE 20 END AS BillingCompanyId
FROM TABLE(GENERATOR(ROWCOUNT => 100));

-- B. OrderRightsInvoice (50 Rows - IDs 1 to 50)
INSERT INTO OrderRightsInvoice
SELECT 
    seq4() + 1 AS Id,
    seq4() + 500 AS OrderHeaderId, -- Links to OrderHeader
    1 AS InvoiceStatusId,
    1 AS RightsFeeId,
    1 AS CurrencyId,
    100 AS CustomerAddressId,
    1 AS InstallmentNo,
    'SO-R-' || (seq4() + 1) AS SAPSalesOrderNumber,
    DATEADD(day, seq4(), '2023-01-01') AS InvoiceDueDate,
    DATEADD(day, seq4(), '2022-12-01') AS CreatedDate,
    DATEADD(day, seq4(), '2022-12-05') AS UpdatedDate,
    'Pay via Wire' AS InvoiceInstructions,
    'Licensing Rights' AS InvoiceDescription,
    'INV-R-' || (seq4() + 1) AS InvoiceReferenceNumber,
    NULL AS CreditedInvoiceId,
    0 AS InvoiceWasCancelled,
    'DOC-R-' || (seq4() + 1) AS SAPDocumentNumber,
    NULL AS ClearingDate,
    1 AS IsDataMartDueDate,
    DATEADD(day, seq4() + 10, '2023-01-01') AS InvoiceProcessedDate
FROM TABLE(GENERATOR(ROWCOUNT => 50));

INSERT INTO OrderRightsInvoiceOrderDetail
SELECT 
    seq4() + 1 AS Id,
    seq4() + 1 AS OrderRightsInvoiceId, -- Links 1-to-1 with Invoice
    seq4() + 1000 AS OrderDetailId,     -- Links to OrderDetail
    1 AS VatCodeId,
    1 AS WithHoldingTaxRecordId,
    CASE WHEN seq4() % 10 = 0 THEN 50 ELSE NULL END AS PseudoInvoicingTypeId,
    2023 AS ProjectionYear,
    '10' AS SAPLineItemNumber,
    -- Licensor Logic: 9=IMG, 8=Agency, 1=Standard
    CASE WHEN seq4() % 3 = 0 THEN 9 WHEN seq4() % 3 = 1 THEN 8 ELSE 1 END AS LicensorId
FROM TABLE(GENERATOR(ROWCOUNT => 50));

-- C. OrderInvoice (Technical - 50 Rows - IDs 51 to 100)
INSERT INTO OrderInvoice
SELECT 
    seq4() + 51 AS Id,
    seq4() + 550 AS OrderHeaderId, -- Different Headers
    1 AS InvoiceStatusId,
    2 AS FeeId,
    2 AS CurrencyId,
    101 AS CustomerAddressId,
    1 AS InstallmentNo,
    'SO-T-' || (seq4() + 51) AS SAPSalesOrderNumber,
    DATEADD(day, seq4(), '2023-02-01') AS InvoiceDueDate,
    DATEADD(day, seq4(), '2023-01-01') AS CreatedDate,
    DATEADD(day, seq4(), '2023-01-05') AS UpdatedDate,
    'Pay via Check' AS InvoiceInstructions,
    'Technical Services' AS InvoiceDescription,
    'INV-T-' || (seq4() + 51) AS InvoiceReferenceNumber,
    NULL AS CreditedInvoiceId,
    0 AS InvoiceWasCancelled,
    'DOC-T-' || (seq4() + 51) AS SAPDocumentNumber,
    NULL AS ClearingDate,
    0 AS IsDataMartDueDate,
    DATEADD(day, seq4() + 10, '2023-02-01') AS InvoiceProcessedDate
FROM TABLE(GENERATOR(ROWCOUNT => 50));

INSERT INTO OrderInvoiceDetail
SELECT 
    seq4() + 51 AS Id,
    seq4() + 51 AS OrderInvoiceId,
    seq4() + 1050 AS OrderDetailId,
    2 AS VatCodeId,
    1 AS WithHoldingTaxRecordId,
    NULL AS PseudoInvoicingTypeId,
    2023 AS ProjectionYear,
    CASE WHEN seq4() % 2 = 0 THEN 10 ELSE 7 END AS LicensorId
FROM TABLE(GENERATOR(ROWCOUNT => 50));

-- D. SAPImportedInvoices (100 Rows linked to above)
-- We mix Open and Cleared status
INSERT INTO SAPImportedInvoices
SELECT 
    seq4() + 1 AS Id,
    'SOL-' || (seq4() + 1) AS SOL_NUMBER,
    CASE 
        WHEN seq4() < 50 THEN 'INV-R-' || (seq4() + 1)  -- First 50 match Rights
        ELSE 'INV-T-' || (seq4() + 1)                   -- Next 50 match Technical
    END AS SAP_INVOICE,
    'DOC-' || (seq4() + 1) AS SAP_ACCTG_DOC,
    CASE WHEN seq4() % 2 = 0 THEN 'CLR-' || (seq4() + 1) ELSE '' END AS SAP_CLEAR_DOC, -- 50% Cleared
    CASE WHEN seq4() % 2 = 0 THEN '2023-06-01' ELSE '' END AS SAP_CLEAR_DATE,
    '2023-01-15' AS SAP_INV_DATE,
    DATEADD(minute, seq4(), '2023-01-15 10:00:00') AS UpdatedDate,
    CASE 
        WHEN seq4() < 50 THEN seq4() + 1    -- Rights IDs 1-50
        ELSE seq4() + 1                     -- Tech IDs 51-100 (Logic simplified, assumes unique IDs across tables for this mock)
    END AS InvoiceId, 
    CASE WHEN seq4() < 50 THEN 'R' ELSE 'T' END AS InvoiceType,
    CASE WHEN seq4() % 2 = 0 THEN 'CLEARED' ELSE 'OPEN' END AS SAP_BILLING_STATUS,
    1 AS StatusId
FROM TABLE(GENERATOR(ROWCOUNT => 100));


table MEDIADMSTAGING.DEV.DIM_INVOICE;

--***************************DIM INVOICE**************************************************************
