{{ config({"tags":["exclude_bigquery", "exclude_bigquery_tests"]}) }}

with test_raw_data as (
    select
        '{"key1":"value1", "key2":{"innerkey2_1":"innervalue2_1", "0":[0, null, "string"]}, "key3": -1234}'
            as varchar_json
)
, test_json_data as (
    select {{xdb.cast_json("varchar_json")}} as json_col from test_raw_data
)

select
    {% if target.type == 'postgres' %}
        json_col->>'key1' as value1,
        json_col->>'key3' as value3
    {% elif target.type == 'snowflake' %}
        json_col:key1 as value1,
        json_col:key3 as value3
    {% endif %}
from test_json_data