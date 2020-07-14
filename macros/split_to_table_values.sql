{%- macro split_to_table_values(table_array) -%}
    {# Used in conjunction with split_to_table, this macro returns the split_to_table
        values associated with the split_to_table function
       ARGS:
         - table_array (string) the table array form of the split_column.
       RETURNS: A new column containing the split data.
    #}
    {%- if target.type ==  'postgres' -%} 
        {{ table_array }}
    {%- elif target.type == 'bigquery' -%}
        {{ table_array }}
    {%- elif target.type == 'snowflake' -%}
        {{ table_array }}.value::VARCHAR
    {%- else -%}
        {{ xdb.not_supported_exception('quote_insensitive') }}
    {%- endif -%}
{%- endmacro -%}

