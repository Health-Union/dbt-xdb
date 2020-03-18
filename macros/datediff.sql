{%- macro datediff(part, left_val, right_val, date_format='%Y-%m-%d') -%}
    {# determines the delta (in `part` units) between first_val and second_val.
       *Note* the order of left_val, right_val is reversed from Snowflake.
       ARGS:
         - part (string) one of 'day', 'week', 'month', 'year'
         - left_val (date/timestamp) the value before the minus in the equation "left - right"
         - right_val (date/timestamp) the value after the minus in the equation "left - right"
         - date_format (pattern) a string pattern for the provided arguments (primarily for BigQuery)
       RETURNS: An integer representing the delta in `part` units
    #}

    {%if part not in ('day','week','month','year',) %}
        {{exceptions.raise_compiler_error("macro datediff for target does not support date part value " ~ part)}}
    {%- endif -%}

    {%- if target.type ==  'postgres' -%} 
        {%- if part == 'year' -%}
            DATE_PART('year',{{left_val}}::DATE) - DATE_PART('year',{{right_val}}::DATE)
        {%- elif part == 'month' -%}
            ((DATE_PART('year',{{left_val}}::DATE) - DATE_PART('year',{{right_val}}::DATE)) * 12)
            +
            (DATE_PART('month',{{left_val}}::DATE) - DATE_PART('month',{{right_val}}::DATE))
        {%- elif part == 'week' -%}
            TRUNC(DATE_PART('day', ({{left_val}}::TIMESTAMP - {{right_val}}::TIMESTAMP))/7)
        {%- elif part == 'day' -%}
            DATE_PART('day', ({{left_val}}::TIMESTAMP - {{right_val}}::TIMESTAMP))
        {%- endif %}

    {%- elif target.type == 'bigquery' -%}

        DATE_DIFF(PARSE_DATE('{{date_format}}', {{left_val}}), 
                  PARSE_DATE('{{date_format}}', {{right_val}}), 
                  {{part|upper}})

    {%- elif target.type == 'snowflake' -%}

        DATE_DIFF({{part}}, {{right_val}},{{left_val}})

    {%- else -%}
        {{exceptions.raise_compiler_error("macro does not support datediff for target " ~ target.type ~ ".")}}
    {%- endif -%}
{%- endmacro -%}

