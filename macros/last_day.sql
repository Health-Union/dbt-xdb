{%- macro last_day(col) -%}
    {#/* Moves column date value to last day of month e.g. 2022-01-01 to 2022-01-31
       ARGS:
         - col (identifier/date/timestamp) the column from where to extract last day of month.
       RETURNS: Last day of month
       SUPPORTS:
            - Postgres
            - Snowflake
    */#}
{%- if target.type ==  'postgres' -%} 
    DATE_TRUNC('month', {{ col }}::DATE) + interval '1 month' - interval '1 day'

{%- elif target.type == 'snowflake' -%}
    LAST_DAY({{ col }}::DATE)

{%- else -%}
    {{ xdb.not_supported_exception('last_day') }}

{%- endif -%}
{%- endmacro -%}
