{{
    config(
        materialized='dynamic_table',
        schema='DEV',
        snowflake_warehouse='COMPUTE_WH',
        target_lag='1 hour',
        on_configuration_change='apply'
    )
}}

select * from {{ ref('dim_invoice_v') }}