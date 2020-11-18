SELECT 
    {{ xdb.generate_daily_time_series_values('2020-01-01', '2020-01-05') }} AS one_day_diff
FROM
    {{xdb.generate_daily_time_series_from('2020-01-01', '2020-01-05')}}