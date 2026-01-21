{% macro generate_schema_name(custom_schema_name, node) -%}
    {%- set default_schema = target.schema -%}
    
    {# If a custom schema is provided in dbt_project.yml, use ONLY that name #}
    {%- if custom_schema_name is not none -%}
        {{ custom_schema_name | trim }}
    
    {# Otherwise, fall back to the default schema defined in your profile #}
    {%- else -%}
        {{ default_schema }}
    {%- endif -%}
{%- endmacro %}