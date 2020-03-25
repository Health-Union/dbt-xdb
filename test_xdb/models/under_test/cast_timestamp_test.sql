WITH 
source_data AS (
SELECT
    '2020-01-01' AS date_col
    ,'2020-01-01 20:20:20' AS timestamp_col
)
SELECT
    {{xdb.cast_timestamp('date_col','timestamp_ntz')}} AS date_ntz
    ,{{xdb.cast_timestamp('date_col','timestamp_tz')}} AS date_tz
    ,{{xdb.cast_timestamp('timestamp_col','timestamp_ntz')}} AS tstamp_ntz
    ,{{xdb.cast_timestamp('timestamp_col','timestamp_tz')}} AS tstamp_tz
FROM source_data
