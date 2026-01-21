{{
    config(
        materialized='dynamic_table',
        snowflake_warehouse='COMPUTE_WH',
        target_lag='1 hour',
        on_configuration_change='apply'
    )
}}

select * from {{ ref('int_dim_invoice') }}