{%- macro split_to_table(split_column, delimeter) -%}
    {# Splits the supplied string type column into rows based on the delimeter 
       ARGS:
         - split_column (string) the column / database / relation name to be split.
         - delimeter (string) the delimeter to use when splitting the split_column
       RETURNS: A new column containing the split data.
    #}
    {%- if target.type ==  'postgres' -%} 
        unnest(string_to_array({{ split_column }}, '{{ delimeter }}' ))
    {%- elif target.type == 'bigquery' -%}
        unnest(split({{ split_column }}, '{{ delimeter }}' ))
    {%- elif target.type == 'snowflake' -%}
        lateral flatten(input => split({{ split_column }}, '{{ delimeter }}' ))
    {%- else -%}
        {{ xdb.not_supported_exception('quote_insensitive') }}
    {%- endif -%}
{%- endmacro -%}

