/*{# xdb: nocoverage #}*/
{%- macro unnest_values(table_array) -%}
    {# Used in conjunction with unnest, this macro returns the unnested
        values associated with the unnest macro
       ARGS:
         - table_array (string) the table array form of the split_column.
       RETURNS: A new column containing the split data.
       SUPPORTS:
            - Postgres
            - Snowflake
            - BigQuery
    #}
    {%- if target.type in ['postgres', 'bigquery'] -%} 
        {{ table_array }}
    {%- elif target.type == 'snowflake' -%}
        {{ table_array }}.value::VARCHAR
    {%- else -%}
        {{ xdb.not_supported_exception('unnest_values') }}
    {%- endif -%}
{%- endmacro -%}