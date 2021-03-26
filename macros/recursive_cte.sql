{%- macro recursive_cte() -%}
    {# Supplies the correct wrapper for recursive CTEs in postgres & snowflake
       NOTE: Bigquery does not currently support recursive CTEs per their docs
       RETURNS: The correct wrapper for the CTE
       SUPPORTS:
            - Postgres
            - Snowflake
    #}
    {%- if target.type ==  'postgres' -%} 
        WITH RECURSIVE 
    {%- elif target.type == 'snowflake' -%}
        WITH 
    {%- else -%}
        {{ xdb.not_supported_exception('quote_insensitive') }}
    {%- endif -%}
{%- endmacro -%}