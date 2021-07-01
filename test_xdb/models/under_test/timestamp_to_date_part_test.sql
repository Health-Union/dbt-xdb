{{ config({"tags":["exclude_bigquery", "exclude_bigquery_tests"]}) }}

WITH
test_data AS (
    SELECT '1980-01-02 03:04:05'::timestamp AS test_timestamp
)

SELECT
    {{ xdb.timestamp_to_date_part("test_timestamp", 'epoch') }} AS seconds_since_epoch
    , {{ xdb.timestamp_to_date_part("test_timestamp", 'year') }} AS year_extract
    , {{ xdb.timestamp_to_date_part("test_timestamp", 'month') }} AS month_extract
    , {{ xdb.timestamp_to_date_part("test_timestamp", 'day') }} AS day_extract
    , {{ xdb.timestamp_to_date_part("test_timestamp", 'hour') }} AS hour_extract
    , {{ xdb.timestamp_to_date_part("test_timestamp", 'minute') }} AS minute_extract
    , {{ xdb.timestamp_to_date_part("test_timestamp", 'second') }} AS second_extract
FROM
    test_data
