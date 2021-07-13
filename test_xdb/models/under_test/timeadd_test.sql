WITH
source_data AS (
    SELECT '2020-01-01 00:00:00' AS date_col
)

SELECT
    {{xdb.timeadd('second', '1', 'date_col')}} AS one_second_added
    , {{xdb.timeadd('second', '-1', 'date_col')}} AS one_second_subtracted
    , {{xdb.timeadd('minute', '1', 'date_col')}} AS one_minute_added
    , {{xdb.timeadd('minute', '-1', 'date_col')}} AS one_minute_subtracted
    , {{xdb.timeadd('hour', '1', 'date_col')}} AS one_hour_added
    , {{xdb.timeadd('hour', '-1', 'date_col')}} AS one_hour_subtracted
FROM
    source_data

