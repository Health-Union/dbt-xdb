/*{# xdb: nocoverage #}*/
{%- macro unnest(array_to_unnest) -%}
    {# Takes an array and splits it into rows of values
       ARGS:
         - array_to_unnest (string) the array to unnest.
       RETURNS: A new column containing the split data.
        SUPPORTS:
            - Postgres
            - Snowflake
            - BigQuery
    #}
    {%- if target.type in ['postgres', 'bigquery'] -%} 
        unnest({{ array_to_unnest }})
    {%- elif target.type == 'snowflake' -%}
        lateral flatten(input => {{ array_to_unnest }})
    {%- else -%}
        {{ xdb.not_supported_exception('unnest') }}
    {%- endif -%}
{%- endmacro -%}

