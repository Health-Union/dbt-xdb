{%- macro any_value(val) -%}
    {#/*
        SUPPORTS:
            - Postgres
            - Snowflake
            - BigQuery
            - Redshift
    */#}
{%- if target.type in ('postgres','redshift',) -%} 
    MAX('{{val}}') 
{%- elif target.type in ('snowflake','bigquery',) -%}
    any_value('{{val}}')
{%- else -%}
    {{ xdb.not_supported_exception('any_value') }}
{%- endif -%}

{%- endmacro -%}

