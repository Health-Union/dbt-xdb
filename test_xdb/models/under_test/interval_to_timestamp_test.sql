SELECT 
    {{ xdb.interval_to_timestamp('second', 3) }} AS three_seconds_second
    , {{ xdb.interval_to_timestamp('second', 180) }} AS three_minutes_second
    , {{ xdb.interval_to_timestamp('second', 10800) }} AS three_hours_second
    , {{ xdb.interval_to_timestamp('second', 120603) }} AS thirty_three_hours_thirty_minutes_three_seconds_second
    , {{ xdb.interval_to_timestamp('minute', 3) }} AS three_minutes_minute
    , {{ xdb.interval_to_timestamp('minute', 180) }} AS three_hours_minute
    , {{ xdb.interval_to_timestamp('minute', 2010) }} AS thirty_three_hours_thirty_minutes_minute
