{%- macro generate_daily_time_series_from(start_date, stop_date) -%}
    {# Used in conjunction with generate_time_series_values, this macro returns a time series
        of values based on the start_date and stop_date in 1 day increments
       ARGS:
         - start_date (date) the start date of the series
         - stop_date (date) the ending date of the series

       RETURNS: A new column containing the generated series.
       SUPPORTS:
            - Postgres
            - Snowflake
    #}

    {%- if target.type in ['postgres'] -%} 
        GENERATE_SERIES('{{ start_date }}'::TIMESTAMP, '{{ stop_date }}'::TIMESTAMP, '1 day')
    {%- elif target.type == 'snowflake' -%}
        {%- set new_start_date = modules.datetime.datetime.strptime(start_date, '%Y-%m-%d') -%}
        {%- set new_stop_date = modules.datetime.datetime.strptime(stop_date, '%Y-%m-%d') -%}
        {% set row_count_value = (new_stop_date - new_start_date).days + 1 -%}
        TABLE(GENERATOR(ROWCOUNT => {{ row_count_value }}))
    {%- else -%}
        {{ xdb.not_supported_exception('generate_time_series_values') }}
    {%- endif -%}
{%- endmacro -%}