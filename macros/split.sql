/*{# xdb: nocoverage #}*/
{%- macro split(split_column, delimeter) -%}
    {#/* Splits the supplied string into an array based on the delimiter
       ARGS:
         - split_column (string) the column / database / relation name to be split.
         - delimeter (string) the delimeter to use when splitting the split_column
       RETURNS: An array of the split string
       SUPPORTS:
            - Postgres
            - Snowflake
            - BigQuery
    */#}
{%- if target.type ==  'postgres' -%} 
    STRING_TO_ARRAY({{ split_column }}, '{{ delimeter }}' )
{%- elif target.type in ['bigquery', 'snowflake'] -%}
    split({{ split_column }}, '{{ delimeter }}' )
{%- else -%}
    {{ xdb.not_supported_exception('split') }}
{%- endif -%}
{%- endmacro -%}

