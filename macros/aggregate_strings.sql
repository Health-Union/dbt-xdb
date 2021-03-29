{%- macro aggregate_strings(val, delim) -%}
    {#
        SUPPORTS:
            - Postgres
            - Snowflake
            - BigQuery
    #}
    {%- if target.type ==  'postgres' -%} 
        string_agg({{ val }}::varchar {{',' if delim else ''}}  {{ delim }})
    {%- elif target.type == 'bigquery' -%}
        string_agg(cast({{val}} as string) {{',' if delim else ''}}  {{ delim }})
    {%- elif target.type == 'snowflake' -%}
        listagg(cast({{ val }} as varchar){{',' if delim else ''}}  {{ delim }})
    {%- else -%}
        {{ xdb.not_supported_exception('aggregate_strings') }}
    {%- endif -%}
{%- endmacro -%}

