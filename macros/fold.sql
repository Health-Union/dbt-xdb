
{%- macro fold(val) -%}
    {#/*
        SUPPORTS:
            - Postgres
            - Snowflake
            - BigQuery
    */#}
{{ xdb.strip_to_single_line(xdb._fold(val)) }}
{%- endmacro -%}


{%- macro _fold(val) -%}
    {#/* folds a value per the target adapter default.
    ARGS:
      - val(string): the value to be folded.
    RETURNS: `val` either upper or lowercase (or unfolded), per the target adapter spec.
    SUPPORTS:
        - Postgres
        - Snowflake
        - BigQuery
    */#}
{%- if target.type == 'postgres' -%}
    {{ val | lower }} 
{%- elif target.type == 'snowflake' -%}
    {{ val | upper }} 
{%- elif target.type == 'bigquery' -%}
    {{ val }} 
{%- else -%}
    {{ xdb.not_supported_exception('fold') }}
{%- endif -%}
{%- endmacro %}
