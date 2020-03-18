
WITH
arguments AS (
    SELECT
        '2020-01-01 23:00:00 UTC'::TIMESTAMP AS base_arg
)

SELECT 
    {{ xdb.datediff('day', "'2020-01-02'","base_arg") }} AS one_day_diff
FROM
    arguments
