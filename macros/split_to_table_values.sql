{%- macro split_to_table_values(table_array) -%}
    {# Used in conjunction with split_to_table, this macro returns the split_to_table
        values associated with the split_to_table macro
    NOTE: This is a wrapper macro for unnest_values.
    ARGS:
         - table_array (string) the table array form of the split_column.
       RETURNS: A new column containing the split data.
    #}
    {%- if target.type in ['postgres', 'bigquery', 'snowflake'] -%} 
        {{ xdb.unnest_values(table_array) }}
    {%- else -%}
        {{ xdb.not_supported_exception('split_to_table_values') }}
    {%- endif -%}
{%- endmacro -%}

