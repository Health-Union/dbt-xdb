{{ config({"tags":["exclude_bigquery", "exclude_bigquery_tests"]}) }}

WITH test_json_data  AS (
    SELECT
        {%- set js = '{"key1":"value1", "key2":{"innerkey2_1":"innervalue2_1", "0":[0, null, "string"]}, "key3": -1234}' %}
        {% if target.type == 'postgres' %}'{{js}}'::json
        {% elif target.type == 'snowflake' %}parse_json('{{js}}')
        {%- endif -%}
             AS json_col
)

SELECT
    json_col
    , {{xdb.json_extract_path_text('json_col', ['key1'])}}  AS key1__val
    /* snowflake seems to reorder object keys, so straight query won't work */
    , LENGTH(REPLACE({{xdb.json_extract_path_text('json_col', ['key2'])}}, ' ', '')) AS key2__val
    , {{xdb.json_extract_path_text('json_col', ['key2', 'innerkey2_1'])}} AS key2_innerkey2_1__val
    , REPLACE({{xdb.json_extract_path_text('json_col', ['key2', '0'])}}, ' ', '')  AS key2_0__val
    , {{xdb.json_extract_path_text('json_col', ['key2', '0', 0])}} AS key2_0__val_0
    , {{xdb.json_extract_path_text('json_col', ['key2', '0', 1])}} AS key2_0__val_1
    , {{xdb.json_extract_path_text('json_col', ['key2', '0', 2])}} AS key2_0__val_2
    , {{xdb.json_extract_path_text('json_col', ['key3'])}} AS key3__val
    , CAST({{xdb.json_extract_path_text('json_col', ['key3'])}} AS INT) AS key3__val_int
FROM test_json_data