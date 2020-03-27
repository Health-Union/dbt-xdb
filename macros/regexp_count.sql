{%- macro regexp_count(value, pattern) -%}
    {# counts how many instances of `pattern` in `value`
       ARGS:
         - value (string) the subject to be searched
         - pattern (string) the regex pattern to search for
       RETURNS: An integer count of patterns in value
    #}
    {%- if target.type ==  'postgres' -%} 
        (select count(values)::int from regexp_matches({{value}},{{pattern}} , 'g') values)
    {%- elif target.type == 'bigquery' -%}

        DATE_DIFF(PARSE_DATE('{{date_format}}', {{left_val}}), 
                  PARSE_DATE('{{date_format}}', {{right_val}}), 
                  {{part|upper}})

    {%- elif target.type == 'snowflake' -%}

        DATEDIFF('{{part}}', {{right_val}},{{left_val}})

    {%- else -%}
        {{exceptions.raise_compiler_error("macro does not support datediff for target " ~ target.type ~ ".")}}
    {%- endif -%}
{%- endmacro -%}

