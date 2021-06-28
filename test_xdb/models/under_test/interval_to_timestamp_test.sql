WITH second_arguments AS (
    SELECT 
        3 AS three_seconds
        , 180 AS three_minutes
        , 10800 AS three_hours
        , 120603 AS tthtmts
)

SELECT
    {{ xdb.interval_to_timestamp('second', "sa.three_seconds") }} AS three_seconds_second
    , {{ xdb.interval_to_timestamp('second', "sa.three_minutes") }} AS three_minutes_second
    , {{ xdb.interval_to_timestamp('second', "sa.three_hours") }} AS three_hours_second
    , {{ xdb.interval_to_timestamp('second', "sa.tthtmts") }} AS thirty_three_hours_thirty_minutes_three_seconds_second
    , {{ xdb.interval_to_timestamp('minute', 3) }} AS three_minutes_minute
    , {{ xdb.interval_to_timestamp('minute', 180) }} AS three_hours_minute
    , {{ xdb.interval_to_timestamp('minute', 2010) }} AS thirty_three_hours_thirty_minutes_minute
FROM
    second_arguments sa
