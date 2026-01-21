{{ config(materialized='view') }}

WITH unioned_contexts AS (
    -- 1. Direct Contact
    SELECT cc.CustomerId, cc.Id as ContactId, ca.Id as CustomerAddressId
    FROM {{ source('media_dm_staging', 'CustomerContact') }} cc
    JOIN {{ source('media_dm_staging', 'CustomerAddress') }} ca ON cc.CustomerId = ca.CustomerId

    UNION

    -- 2. Internal Allocation (Rights)
    SELECT DISTINCT oh.CustomerId, cc.Id, i.CustomerAddressId
    FROM {{ source('media_dm_staging', 'InternalAllocation') }} p
    JOIN {{ source('media_dm_staging', 'OrderHeader') }} oh ON oh.Id = p.OrderHeaderId
    LEFT JOIN {{ source('media_dm_staging', 'OrderRightsInvoiceOrderDetail') }} id ON id.Id = p.OrderInvoiceId
    LEFT JOIN {{ source('media_dm_staging', 'OrderRightsInvoice') }} i ON i.Id = id.OrderRightsInvoiceId
    LEFT JOIN {{ source('media_dm_staging', 'CustomerContact') }} cc ON cc.CustomerId = oh.CustomerId AND cc.Id = i.CustomerContactId

    UNION
    
    -- 3. Internal Allocation (Technical)
    SELECT DISTINCT oh.CustomerId, cc.Id, i.CustomerAddressId
    FROM {{ source('media_dm_staging', 'InternalAllocation') }} p
    JOIN {{ source('media_dm_staging', 'OrderHeader') }} oh ON oh.Id = p.OrderHeaderId
    LEFT JOIN {{ source('media_dm_staging', 'OrderInvoiceDetail') }} id ON id.Id = p.OrderInvoiceId
    LEFT JOIN {{ source('media_dm_staging', 'OrderInvoice') }} i ON i.Id = id.OrderInvoiceId
    LEFT JOIN {{ source('media_dm_staging', 'CustomerContact') }} cc ON cc.CustomerId = oh.CustomerId AND cc.Id = i.CustomerContactId

    UNION

    -- 4. Rights Invoices
    SELECT DISTINCT oh.CustomerId, cc.Id, invd.CustomerAddressId
    FROM {{ source('media_dm_staging', 'OrderHeader') }} oh
    JOIN {{ source('media_dm_staging', 'OrderDetail') }} od ON oh.Id = od.OrderHeaderId
    JOIN {{ source('media_dm_staging', 'W_OrderRightsInvoiceOrderDetailAudit') }} invd ON invd.OrderDetailId = od.Id
    LEFT JOIN {{ source('media_dm_staging', 'CustomerContact') }} cc ON cc.Id = invd.CustomerContactId

    UNION

    -- 5. Technical Invoices
    SELECT DISTINCT oh.CustomerId, cc.Id, invd.CustomerAddressId
    FROM {{ source('media_dm_staging', 'OrderHeader') }} oh
    JOIN {{ source('media_dm_staging', 'OrderDetail') }} od ON oh.Id = od.OrderHeaderId
    JOIN {{ source('media_dm_staging', 'W_OrderInvoiceDetailAudit') }} invd ON invd.OrderDetailId = od.Id
    LEFT JOIN {{ source('media_dm_staging', 'CustomerContact') }} cc ON cc.Id = invd.CustomerContactId

    UNION

    -- 6. Contracts
    SELECT DISTINCT oh.CustomerId, cc.Id, oi.CustomerAddressId
    FROM {{ source('media_dm_staging', 'OrderDetail') }} od
    JOIN {{ source('media_dm_staging', 'OrderHeader') }} oh ON oh.Id = od.OrderHeaderId
    LEFT JOIN {{ source('media_dm_staging', 'Contract') }} oi ON od.ContractId = oi.Id
    LEFT JOIN {{ source('media_dm_staging', 'CustomerContact') }} cc ON cc.CustomerId = oh.CustomerId AND cc.Id = oi.CustomerContactId

    UNION

    -- 7. Projections
    SELECT DISTINCT CustomerId, -1, -1
    FROM {{ source('media_dm_staging', 'Projection_aud') }}
)
SELECT DISTINCT
    COALESCE(CustomerId, -1) as CustomerId,
    COALESCE(ContactId, -1) as ContactId,
    COALESCE(CustomerAddressId, -1) as CustomerAddressId
FROM unioned_contexts