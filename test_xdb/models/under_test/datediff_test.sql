
WITH
arguments AS (
    SELECT
        '2020-01-01 23:00:00 UTC'::TIMESTAMP AS base_arg
)

SELECT 
    {{ xdb.datediff('day', "'2020-01-02'","base_arg") }} AS one_day_diff
    ,{{ xdb.datediff('month',"'2020-01-15'","base_arg") }} AS two_week_diff
    ,{{ xdb.datediff('month',"'2020-04-02'","base_arg") }} AS three_month_diff
FROM
    arguments
