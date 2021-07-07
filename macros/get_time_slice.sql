{%- macro get_time_slice(date_or_time_expr, slice_length, date_or_time_part, start_or_end) -%}
    {#/* Calculates the beginning or end of a “slice” of time, 
      where the length of the slice is a multiple of a standard unit of time (minute, hour, day, etc.).
      This function can be used to calculate the start and end times of fixed-width “buckets” into which data can be categorized..
       ARGS:
         - date_or_time_expr (date or time): This macro returns the start or end of the slice that contains this date or time.
         - slice_length (int): the width of the slice, i.e. how many units of time are contained in the slice. For example, if the unit is DAY and the slice_length is 2, then each slice is 2 days wide. The slice_length must be an integer greater than or equal to 1.
         - date_or_time_part (string): Time unit for the slice length. The value must be a string containing one of the values listed below:
            MINUTE, HOUR, DAY, YEAR
            NOTE: This macro has not been tested for second, week, month, or quarter intervals.
         - start_or_end (string): This is an optional constant parameter that determines whether the start or end of the slice should be returned.
            Supported values are ‘START’ or ‘END’. The values are case insensitive.
            The default value is ‘START’.
       RETURNS: a timestamp
       SUPPORTS:
            - Postgres
            - Snowflake
            - BigQuery
    */#}
{%- if target.type == 'postgres' -%}
    CASE
        WHEN '{{ start_or_end }}' = 'END'
            THEN 'epoch' ::timestamp + '{{ slice_length }} {{ date_or_time_part }}' ::interval * (EXTRACT(epoch FROM ({{ date_or_time_expr }} + '{{ slice_length }} {{ date_or_time_part }}' ::interval))::int4 / EXTRACT(epoch FROM '{{ slice_length }} {{ date_or_time_part }}' ::interval)::int4)
        ELSE 'epoch' ::timestamp + '{{ slice_length }} {{ date_or_time_part }}' ::interval * (EXTRACT(epoch FROM {{ date_or_time_expr }})::int4 / EXTRACT(epoch FROM '{{ slice_length }} {{ date_or_time_part }}' ::interval)::int4)
    END
{%- elif target.type == 'snowflake' -%}
    TIME_SLICE({{ date_or_time_expr }}::timestamp, {{ slice_length }}, '{{ date_or_time_part }}', '{{ start_or_end }}')
{%- else -%}
    {{ exceptions.raise_compiler_error("macro does not support get_time_slice for target " ~ target.type ~ ".") }}
{%- endif -%}
{%- endmacro -%}