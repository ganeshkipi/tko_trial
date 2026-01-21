{% macro get_customer_key(customer_id, contact_id, address_id) %}
    MD5(CONCAT(
        COALESCE(CAST({{ customer_id }} AS VARCHAR), '-1'), ':',
        COALESCE(CAST({{ contact_id }} AS VARCHAR), '-1'), ':',
        COALESCE(CAST({{ address_id }} AS VARCHAR), '-1')
    ))
{% endmacro %}

{% macro get_customer_hash() %}
    MD5(CONCAT(
        COALESCE(CAST(CustomerKey AS VARCHAR), ''), '|',
        COALESCE(CAST(SourceCustomerId AS VARCHAR), ''), '|',
        COALESCE(CAST(SourceContactId AS VARCHAR), ''), '|',
        COALESCE(CAST(SourceCustomerAddressId AS VARCHAR), ''), '|',
        COALESCE(CAST(CustomerNo AS VARCHAR), ''), '|',
        COALESCE(CAST(CustomerName AS VARCHAR), ''), '|',
        COALESCE(CAST(CustomerShortName AS VARCHAR), ''), '|',
        COALESCE(CAST(ContactName AS VARCHAR), ''), '|',
        COALESCE(CAST(ProjectionTerritory AS VARCHAR), ''), '|',
        COALESCE(CAST(SAPCustomerNumber AS VARCHAR), ''), '|',
        COALESCE(CAST(SAPPayerNumber AS VARCHAR), ''), '|',
        COALESCE(CAST(SOLId AS VARCHAR), ''), '|',
        COALESCE(CAST(RightsSelection AS VARCHAR), ''), '|',
        COALESCE(CAST(TerritorySelection AS VARCHAR), ''), '|',
        COALESCE(CAST(LanguageSelection AS VARCHAR), ''), '|',
        COALESCE(CAST(NumberOfTransmissions AS VARCHAR), ''), '|',
        COALESCE(CAST(NumberOfTransmissionsName AS VARCHAR), ''), '|',
        COALESCE(CAST(GeneralTypeLive AS VARCHAR), ''), '|',
        COALESCE(CAST(GeneralTypeProduced AS VARCHAR), ''), '|',
        COALESCE(CAST(DeliveryFormat AS VARCHAR), ''), '|',
        COALESCE(CAST(FrameRate AS VARCHAR), ''), '|',
        COALESCE(CAST(DeliveryMethod AS VARCHAR), ''), '|',
        COALESCE(CAST(Comment AS VARCHAR), ''), '|',
        COALESCE(CAST(CustomerType AS VARCHAR), ''), '|',
        COALESCE(CAST(AudioConfig AS VARCHAR), ''), '|',
        COALESCE(CAST(CustomerState AS VARCHAR), ''), '|',
        COALESCE(CAST(FrameResolution AS VARCHAR), ''), '|',
        COALESCE(CAST(CustomerAddressAirline AS VARCHAR), ''), '|',
        COALESCE(CAST(CustomerInFlightDefaultsCurrency AS VARCHAR), ''), '|',
        COALESCE(CAST(CustomerInFlightDefaultsAirline AS VARCHAR), ''), '|',
        COALESCE(CAST(CustomerInFlightRightsAirline AS VARCHAR), ''), '|',
        COALESCE(CAST(CustomerContactAirline AS VARCHAR), ''), '|',
        COALESCE(TO_CHAR(FirstUnblockedDate, 'YYYY-MM-DD'), ''), '|',
        COALESCE(CAST(FirstUnblockedBy AS VARCHAR), ''), '|',
        COALESCE(TO_CHAR(UnblockedDate, 'YYYY-MM-DD'), ''), '|',
        COALESCE(CAST(UnblockedBy AS VARCHAR), ''), '|',
        COALESCE(TO_CHAR(CreatedDate, 'YYYY-MM-DD'), ''), '|',
        COALESCE(CAST(CreatedBy AS VARCHAR), '')
    ))
{% endmacro %}