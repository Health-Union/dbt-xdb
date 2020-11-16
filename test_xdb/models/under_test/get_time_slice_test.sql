WITH
timestamps AS (
    SELECT
        '2019-01-01 14:00:00'::timestamp AS ts
    UNION ALL
    SELECT
        '2019-01-01 14:00:00 -0500'::timestamp AS ts
    UNION ALL
    SELECT
        '2019-01-01 14:00:00 +0200'::timestamp AS ts
)
   
SELECT
    {{ xdb.get_time_slice('ts::timestamp', 1, 'MINUTE', 'START') }} AS one_minute_slice_start
   , {{ xdb.get_time_slice('ts::timestamp', 1, 'MINUTE', 'END') }} AS one_minute_slice_end
   , {{ xdb.get_time_slice('ts::timestamp', 10, 'MINUTE', 'START') }} AS ten_minute_slice_start
   , {{ xdb.get_time_slice('ts::timestamp', 10, 'MINUTE', 'END') }} AS ten_minute_slice_end
   , {{ xdb.get_time_slice('ts::timestamp', 1, 'HOUR', 'START') }} AS one_hour_slice_start
   , {{ xdb.get_time_slice('ts::timestamp', 1, 'HOUR', 'END') }} AS one_hour_slice_end
   , {{ xdb.get_time_slice('ts::timestamp', 10, 'HOUR', 'START') }} AS ten_hour_slice_start
   , {{ xdb.get_time_slice('ts::timestamp', 10, 'HOUR', 'END') }} AS ten_hour_slice_end
   , {{ xdb.get_time_slice('ts::timestamp', 1, 'DAY', 'START') }} AS one_day_slice_start
   , {{ xdb.get_time_slice('ts::timestamp', 1, 'DAY', 'END') }} AS one_day_slice_end
   , {{ xdb.get_time_slice('ts::timestamp', 10, 'DAY', 'START') }} AS ten_day_slice_start
   , {{ xdb.get_time_slice('ts::timestamp', 10, 'DAY', 'END') }} AS ten_day_slice_end
-- Can't figure out how to get postgres and snowflake to give same answers for week and month
-- Quarter?
   , {{ xdb.get_time_slice('ts::timestamp', 1, 'YEAR', 'START') }} AS one_year_slice_start
   , {{ xdb.get_time_slice('ts::timestamp', 1, 'YEAR', 'END') }} AS one_year_slice_end
   , {{ xdb.get_time_slice('ts::timestamp', 10, 'YEAR', 'START') }} AS ten_year_slice_start
   , {{ xdb.get_time_slice('ts::timestamp', 10, 'YEAR', 'END') }} AS ten_year_slice_end
FROM
   timestamps
