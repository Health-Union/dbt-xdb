{%- macro date_part_day_of_week(val) -%}
    {#/* ports DATE_PART's day of week functionality for `val`.
       ARGS:
         - val (identifier/date/timestamp) the value from where to extract the number indicating the day of the week.
       RETURNS: The integer indicating the day of week (0 for Sunday).
       SUPPORTS:
            - Postgres
            - Snowflake
    */#}
{%- if target.type ==  'postgres' -%} 
    DATE_PART('DOW', {{val}}::DATE)

{%- elif target.type == 'snowflake' -%}
    DATE_PART(DAYOFWEEK, {{val}}::DATE)

{%- else -%}
    {{ xdb.not_supported_exception('date_part_day_of_week') }}
{%- endif -%}
{%- endmacro -%}
