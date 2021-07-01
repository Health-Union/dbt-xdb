{%- macro datediff(part, left_val, right_val, date_format='%Y-%m-%d') -%}
    {#/* determines the delta (in `part` units) between first_val and second_val.
       *Note* the order of left_val, right_val is reversed from Snowflake.
       ARGS:
         - part (string) one of 'second', 'minute', 'hour', 'day', 'week', 'month', 'year', 'quarter'
         - left_val (date/timestamp) the value before the minus in the equation "left - right"
         - right_val (date/timestamp) the value after the minus in the equation "left - right"
         - date_format (pattern) a string pattern for the provided arguments (primarily for BigQuery)
       RETURNS: An integer representing the delta in `part` units
       SUPPORTS:
            - Postgres
            - Snowflake
            - BigQuery
    */#}
{%- set part = part |lower -%}
{%if part not in ('second', 'minute', 'hour', 'day','week','month','year','quarter',) %}
    {{exceptions.raise_compiler_error("macro datediff for target does not support date part value " ~ part)}}
{%- endif -%}

{%- if target.type ==  'postgres' -%}
    {%- if part == 'year' -%}
        ((DATE_PART('year', {{left_val}} ::DATE) - DATE_PART('year', {{right_val}}:: DATE)))
    {%- elif part == 'quarter' -%}
        ((((DATE_PART('year', {{left_val}} ::DATE) - DATE_PART('year', {{right_val}}:: DATE)) * 4)

        + (TRUNC((DATE_PART('month', {{left_val}} ::DATE) - DATE_PART('month', {{right_val}}:: DATE)) / 4))))
    {%- elif part == 'month' -%}
        ((((DATE_PART('year', {{left_val}} ::DATE) - DATE_PART('year', {{right_val}}:: DATE)) * 12)

        + (DATE_PART('month', {{left_val}} :: DATE) - DATE_PART('month', {{right_val}} :: DATE))))
    {%- elif part == 'week' -%}
        ((TRUNC(DATE_PART('day', ({{left_val}} ::TIMESTAMP - {{right_val}} :: TIMESTAMP)) / 7)))
    {%- elif part == 'day' -%}
        ((DATE_PART('day', ({{left_val}} :: TIMESTAMP - {{right_val}} :: TIMESTAMP))))
    {%- elif part =='hour' -%}
        (({{ xdb.datediff('day', left_val, right_val) }} * 24

        + DATE_PART('hour', {{left_val}} :: TIMESTAMP - {{right_val}} :: TIMESTAMP)))
    {%- elif part =='minute' -%}
        (({{ xdb.datediff('hour', left_val, right_val) }} * 60

        + DATE_PART('minute', {{left_val}} ::TIMESTAMP - {{right_val}}:: TIMESTAMP)))
    {%- elif part =='second' -%}
        (({{ xdb.datediff('minute', left_val, right_val) }} * 60

        + DATE_PART('second', {{left_val}} :: TIMESTAMP - {{right_val}}:: TIMESTAMP)))
    {%- endif %}


{%- elif target.type == 'bigquery' -%}
    {% if part in ('second', 'minute', 'hour') %}
        ((TIMESTAMP_DIFF(PARSE_TIMESTAMP('{{date_format}}', FORMAT_TIMESTAMP('{{date_format}}', {{ xdb.cast_timestamp(left_val, 'timestamp') }})),
                    PARSE_TIMESTAMP('{{date_format}}', FORMAT_TIMESTAMP('{{date_format}}', {{ xdb.cast_timestamp(right_val, 'timestamp') }})),
                    {{part|upper}})))
    {% else %}
        ((DATE_DIFF(PARSE_DATE('{{date_format}}', {{left_val}}),
                    PARSE_DATE('{{date_format}}', {{right_val}}),
                    {{part|upper}})))
    {%- endif %}

{%- elif target.type == 'snowflake' -%}

    ((DATEDIFF('{{part}}', {{right_val}},{{left_val}})))

{%- else -%}
    {{ xdb.not_supported_exception('datediff') }}
{%- endif -%}
{%- endmacro -%}
