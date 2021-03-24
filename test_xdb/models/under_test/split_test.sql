/* TODO split is supported for bigquery. tests should support that */
{{ config({"tags":["exclude_bigquery", "exclude_bigquery_tests"]}) }}

{% if target.type == 'postgres' %}
    {% set arr_len_func = 'array_length' %}
    {% set arr_len_xarg = ',1' %}
{% elif target.type == 'snowflake' %}
    {% set arr_len_func = 'array_size' %}
    {% set arr_len_xarg = '' %}
{% endif %}

with test_table as
(
    select
        'string to split on spaces' as space_delim,
        'string-to-split-on-dashes' as dash_delim
)
SELECT
    {{arr_len_func}}({{xdb.split("'word with spaces'", " ")}}{{arr_len_xarg}}) AS spaces_str_len
    ,{{arr_len_func}}({{xdb.split("'100-200-300'", "-")}}{{arr_len_xarg}}) AS dashes_str_len
    ,{{arr_len_func}}({{xdb.split("space_delim", " ")}}{{arr_len_xarg}}) AS spaces_col_len
    ,{{arr_len_func}}({{xdb.split("dash_delim", "-")}}{{arr_len_xarg}}) AS dashes_col_len
from test_table