{%- if target.type == 'postgres' -%}
    {% set arr_len_func = 'ARRAY_LENGTH' %}
    {%- set arr_len_xarg = ', 1' -%}
{% elif target.type == 'snowflake' -%}
    {% set arr_len_func = 'ARRAY_SIZE' %}
    {% set arr_len_xarg = '' %}
{% elif target.type == 'bigquery' %}
    {% set arr_len_func = 'array_length' %}
    {% set arr_len_xarg = '' %}
{%- endif %}

WITH test_table AS (
    SELECT
        'string to split on spaces' AS space_delim
        , 'string-to-split-on-dashes' AS dash_delim
)

SELECT
    {{arr_len_func}}({{xdb.split("'word with spaces'", " ")}}{{arr_len_xarg}}) AS spaces_str_len
    , {{arr_len_func}}({{xdb.split("'100-200-300'", "-")}}{{arr_len_xarg}}) AS dashes_str_len
    , {{arr_len_func}}({{xdb.split("space_delim", " ")}}{{arr_len_xarg}}) AS spaces_col_len
    , {{arr_len_func}}({{xdb.split("dash_delim", "-")}}{{arr_len_xarg}}) AS dashes_col_len
FROM test_table