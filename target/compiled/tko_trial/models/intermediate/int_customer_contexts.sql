

WITH unioned_contexts AS (
    -- 1. Direct Contact
    SELECT cc.CustomerId, cc.Id as ContactId, ca.Id as CustomerAddressId
    FROM MediaDMStaging.dbo.CustomerContact cc
    JOIN MediaDMStaging.dbo.CustomerAddress ca ON cc.CustomerId = ca.CustomerId

    UNION

    -- 2. Internal Allocation (Rights)
    SELECT DISTINCT oh.CustomerId, cc.Id, i.CustomerAddressId
    FROM MediaDMStaging.dbo.InternalAllocation p
    JOIN MediaDMStaging.dbo.OrderHeader oh ON oh.Id = p.OrderHeaderId
    LEFT JOIN MediaDMStaging.dbo.OrderRightsInvoiceOrderDetail id ON id.Id = p.OrderInvoiceId
    LEFT JOIN MediaDMStaging.dbo.OrderRightsInvoice i ON i.Id = id.OrderRightsInvoiceId
    LEFT JOIN MediaDMStaging.dbo.CustomerContact cc ON cc.CustomerId = oh.CustomerId AND cc.Id = i.CustomerContactId

    UNION
    
    -- 3. Internal Allocation (Technical)
    SELECT DISTINCT oh.CustomerId, cc.Id, i.CustomerAddressId
    FROM MediaDMStaging.dbo.InternalAllocation p
    JOIN MediaDMStaging.dbo.OrderHeader oh ON oh.Id = p.OrderHeaderId
    LEFT JOIN MediaDMStaging.dbo.OrderInvoiceDetail id ON id.Id = p.OrderInvoiceId
    LEFT JOIN MediaDMStaging.dbo.OrderInvoice i ON i.Id = id.OrderInvoiceId
    LEFT JOIN MediaDMStaging.dbo.CustomerContact cc ON cc.CustomerId = oh.CustomerId AND cc.Id = i.CustomerContactId

    UNION

    -- 4. Rights Invoices
    SELECT DISTINCT oh.CustomerId, cc.Id, invd.CustomerAddressId
    FROM MediaDMStaging.dbo.OrderHeader oh
    JOIN MediaDMStaging.dbo.OrderDetail od ON oh.Id = od.OrderHeaderId
    JOIN MediaDMStaging.dbo.W_OrderRightsInvoiceOrderDetailAudit invd ON invd.OrderDetailId = od.Id
    LEFT JOIN MediaDMStaging.dbo.CustomerContact cc ON cc.Id = invd.CustomerContactId

    UNION

    -- 5. Technical Invoices
    SELECT DISTINCT oh.CustomerId, cc.Id, invd.CustomerAddressId
    FROM MediaDMStaging.dbo.OrderHeader oh
    JOIN MediaDMStaging.dbo.OrderDetail od ON oh.Id = od.OrderHeaderId
    JOIN MediaDMStaging.dbo.W_OrderInvoiceDetailAudit invd ON invd.OrderDetailId = od.Id
    LEFT JOIN MediaDMStaging.dbo.CustomerContact cc ON cc.Id = invd.CustomerContactId

    UNION

    -- 6. Contracts
    SELECT DISTINCT oh.CustomerId, cc.Id, oi.CustomerAddressId
    FROM MediaDMStaging.dbo.OrderDetail od
    JOIN MediaDMStaging.dbo.OrderHeader oh ON oh.Id = od.OrderHeaderId
    LEFT JOIN MediaDMStaging.dbo.Contract oi ON od.ContractId = oi.Id
    LEFT JOIN MediaDMStaging.dbo.CustomerContact cc ON cc.CustomerId = oh.CustomerId AND cc.Id = oi.CustomerContactId

    UNION

    -- 7. Projections
    SELECT DISTINCT CustomerId, -1, -1
    FROM MediaDMStaging.dbo.Projection_aud
)
SELECT DISTINCT
    COALESCE(CustomerId, -1) as CustomerId,
    COALESCE(ContactId, -1) as ContactId,
    COALESCE(CustomerAddressId, -1) as CustomerAddressId
FROM unioned_contexts