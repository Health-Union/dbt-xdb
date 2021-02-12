{{ config({"tags":["exclude_bigquery", "exclude_bigquery_tests"]}) }}
WITH
inputs AS (
    SELECT
        5 AS x_i
        , 1 AS x_0
        , 100 AS y_0
        , 10 AS x_1
        , 1000 AS y_1
)
   
SELECT
    {{ xdb.linear_interpolate("x_i", "x_0", "y_0", "x_1", "y_1") }} AS interpolated
FROM
   inputs
