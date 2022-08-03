{{ config({"tags":["exclude_bigquery", "exclude_bigquery_tests"]}) }}

WITH
source_data AS (
    SELECT 
        '2020-01-01 00:00:00' AS date_col_string
        , '2020-01-01 00:00:00'::TIMESTAMP AS date_col_timestamp
)

, string_handled_data AS (
SELECT
--cast to timestamp logic block check
    {{xdb.timeadd('second', '1', 'date_col_string')}} AS one_second_added
    , {{xdb.timeadd('second', '-1', 'date_col_string')}} AS one_second_subtracted
    , {{xdb.timeadd('minute', '1', 'date_col_string')}} AS one_minute_added
    , {{xdb.timeadd('minute', '-1', 'date_col_string')}} AS one_minute_subtracted
    , {{xdb.timeadd('hour', '1', 'date_col_string')}} AS one_hour_added
    , {{xdb.timeadd('hour', '-1', 'date_col_string')}} AS one_hour_subtracted
FROM
    source_data
)

, timestamp_handled_data AS (
SELECT
--NO cast to timestamp logic block check
    , {{xdb.timeadd('second', '1', 'date_col_timestamp', false)}} AS one_second_added
    , {{xdb.timeadd('second', '-1', 'date_col_timestamp', false)}} AS one_second_subtracted
    , {{xdb.timeadd('minute', '1', 'date_col_timestamp', false)}} AS one_minute_added
    , {{xdb.timeadd('minute', '-1', 'date_col_timestamp', false)}} AS one_minute_subtracted
    , {{xdb.timeadd('hour', '1', 'date_col_timestamp', false)}} AS one_hour_added
    , {{xdb.timeadd('hour', '-1', 'date_col_timestamp', false)}} AS one_hour_subtracted
FROM
    source_data
)

, unioned_data AS (
    SELECT * FROM timestamp_handled_data
    UNION
    SELECT * FROM string_handled_data
)

SELECT * FROM unioned_data