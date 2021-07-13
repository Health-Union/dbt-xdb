WITH
values_of_things AS (
    SELECT 1 AS value_col
    UNION ALL
    SELECT 3 AS value_col
    UNION ALL
    SELECT 5 AS value_col
)

SELECT {{xdb.any_value(value_col)}} AS value_col
FROM values_of_things

