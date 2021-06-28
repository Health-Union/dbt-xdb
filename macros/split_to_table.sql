{%- macro split_to_table(split_column, delimeter) -%}
    {#/* Splits the supplied string type column into rows based on the delimeter 
       ARGS:
         - split_column (string) the column / database / relation name to be split.
         - delimeter (string) the delimeter to use when splitting the split_column
       RETURNS: A new column containing the split data.
       SUPPORTS:
            - Postgres
            - Snowflake
            - BigQuery
    */#}
{%- if target.type in ['postgres', 'bigquery', 'snowflake'] -%} 
    {{ xdb.unnest(xdb.split(split_column, delimeter )) }}
{%- else -%}
    {{ xdb.not_supported_exception('split_to_table') }}
{%- endif -%}
{%- endmacro -%}

