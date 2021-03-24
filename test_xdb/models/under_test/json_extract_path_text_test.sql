{{ config({"tags":["exclude_bigquery", "exclude_bigquery_tests"]}) }}

with test_json_data as (
    select
        {% set js = '{"key1":"value1", "key2":{"innerkey2_1":"innervalue2_1", "0":[0, null, "string"]}, "key3": -1234}' %}
        {% if target.type == 'postgres' %}'{{js}}'::json
        {% elif target.type == 'snowflake' %}parse_json('{{js}}')
        {% endif %}
            as json_col
)
select
    json_col,
    {{xdb.json_extract_path_text('json_col', ['key1'])}} as key1__val,
    /* snowflake seems to reorder object keys, so straight query won't work */
    length(replace({{xdb.json_extract_path_text('json_col', ['key2'])}}, ' ', '')) as key2__val,
    {{xdb.json_extract_path_text('json_col', ['key2', 'innerkey2_1'])}} as key2_innerkey2_1__val,
    replace({{xdb.json_extract_path_text('json_col', ['key2', '0'])}}, ' ', '') as key2_0__val,
    {{xdb.json_extract_path_text('json_col', ['key2', '0', 0])}} as key2_0__val_0,
    {{xdb.json_extract_path_text('json_col', ['key2', '0', 1])}} as key2_0__val_1,
    {{xdb.json_extract_path_text('json_col', ['key2', '0', 2])}} as key2_0__val_2,
    {{xdb.json_extract_path_text('json_col', ['key3'])}} as key3__val,
    cast({{xdb.json_extract_path_text('json_col', ['key3'])}} as int) as key3__val_int
from test_json_data