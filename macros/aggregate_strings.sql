{%- macro aggregate_strings(val, delim) -%}
    {#/*
        SUPPORTS:
            - Postgres
            - Snowflake
            - BigQuery
    */#}
    {%- if target.type == 'postgres' -%} 
        STRING_AGG({{ val }}::VARCHAR{{',' if delim else ''}} {{ delim }})
    {%- elif target.type == 'bigquery' -%}
        string_agg(cast({{val}} as string) {{',' if delim else ''}} {{ delim }})
    {%- elif target.type == 'snowflake' -%}
        LISTAGG(CAST({{ val }} AS VARCHAR){{',' if delim else ''}} {{ delim }})
    {%- else -%}
        {{ xdb.not_supported_exception('aggregate_strings') }}
    {%- endif -%}
{%- endmacro -%}


