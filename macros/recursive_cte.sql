{%- macro recursive_cte() -%}
    {# Supplies the correct wrapper for recursive CTEs in postgres & snowflake
       NOTE: Bigquery does not currently support recursive CTEs per their docs
       ARGS:
         - none
       RETURNS: The correct wrapper for the CTE
    #}
    {%- if target.type ==  'postgres' -%} 
        WITH RECURSIVE 
    {%- elif target.type == 'snowflake' -%}
        WITH 
    {%- else -%}
        {{ xdb.not_supported_exception('quote_insensitive') }}
    {%- endif -%}
{%- endmacro -%}