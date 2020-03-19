
WITH
arguments AS (
    SELECT
        '2020-01-01' AS base_arg
)

SELECT 
    {{ xdb.datediff('day',"'2020-01-02'","base_arg") }} AS one_day_diff
    ,{{ xdb.datediff('week',"'2020-01-16'","base_arg") }} AS two_week_diff
    ,{{ xdb.datediff('month',"'2020-04-02'","base_arg") }} AS three_month_diff
    ,{{ xdb.datediff('year',"'2024-01-01'","base_arg") }} AS four_year_diff
FROM
    arguments
