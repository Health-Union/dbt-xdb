{%- macro generate_daily_time_series_values(start_date, stop_date) -%}
    {#/* Used in conjunction with generate_daily_time_series_from, this macro returns a time series
        of values based on the start_date and stop_date using 1 day increments
       ARGS:
         - start_date (date) the start date of the series
         - stop_date (date) the ending date of the series
       RETURNS: A new column containing the generated series.
       SUPPORTS:
            - Postgres
            - Snowflake
    */#}

{%- if target.type in ['postgres'] -%} 
    generate_series
{%- elif target.type == 'snowflake' -%}
    DATEADD(day, '+' || ROW_NUMBER() OVER (ORDER BY SEQ4()), TO_TIMESTAMP('{{ start_date }}') - INTERVAL '1 day')
{%- else -%}
    {{ xdb.not_supported_exception('generate_time_series_values') }}
{%- endif -%}
{%- endmacro -%}