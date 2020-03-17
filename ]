
WITH
arguments AS (
    SELECT
        '2020-01-01 23:00:00 UTC'::TIMESTAMP AS base_arg
)

SELECT 
    {{ xdb.datediff('days', "base_arg::date","'2020-01-02'::date") }} AS one_day_diff
FROM
    base_arg
