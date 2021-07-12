{{ config({"tags":["exclude_bigquery", "exclude_bigquery_tests"]}) }}

WITH test_raw_data AS (
    SELECT '{"key1":"value1", "key2":{"innerkey2_1":"innervalue2_1", "0":[0, null, "string"]}, "key3": -1234}' AS varchar_json
)

, test_json_data AS (
    SELECT {{xdb.cast_json("varchar_json")}} AS json_col FROM test_raw_data
)

SELECT
{% if target.type == 'postgres' %}
    json_col->>'key1' AS value1 --noqa
    , json_col->>'key3' AS value3--noqa
{% elif target.type == 'snowflake' %}
    json_col:key1 AS value1 --noqa
    , json_col:key3 AS value3 --noqa
{% endif %}
FROM test_json_data