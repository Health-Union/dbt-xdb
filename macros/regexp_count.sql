{%- macro regexp_count(value, pattern) -%}
    {# counts how many instances of `pattern` in `value`
       ARGS:
         - value (string) the subject to be searched
         - pattern (string) the regex pattern to search for
       RETURNS: An integer count of patterns in value
    #}
    {%- if target.type ==  'postgres' -%} 
        (SELECT count(values)::int from regexp_matches({{value}},{{pattern}} , 'g') values)
    {%- elif target.type == 'bigquery' -%}
        (SELECT array_length(regexp_extract_all({{value}}, r{{pattern}})))
    {%- elif target.type == 'snowflake' -%}

    {%- else -%}
        {{exceptions.raise_compiler_error("macro does not support regexp_count for target " ~ target.type ~ ".")}}
    {%- endif -%}
{%- endmacro -%}

