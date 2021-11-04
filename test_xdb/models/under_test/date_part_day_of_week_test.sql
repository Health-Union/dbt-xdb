WITH
source_data AS (
    SELECT
        '2021-01-03' AS date_sunday
        , '2021-01-06 00:01:11 +01:00' AS datetime_tz_wednesday
        , '2021-01-08 00:01:11' AS datetime_no_tz_friday
)

SELECT
    {{xdb.date_part_day_of_week('date_sunday')}} AS day_number_sunday
    , {{xdb.date_part_day_of_week('datetime_tz_wednesday')}} AS day_number_wednesday
    , {{xdb.date_part_day_of_week('datetime_no_tz_friday')}} AS day_number_friday
FROM
    source_data
