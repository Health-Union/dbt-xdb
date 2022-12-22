{{ config({"tags":["exclude_bigquery", "exclude_bigquery_tests"]}) }}
WITH
inputs AS (
    SELECT
        '2022-01-01' AS date1
        , '2022-02-24' AS date2
        , '2024-02-24' AS date3
)

SELECT 
    {{ xdb.last_day("date1") }} AS last_day_jan
    , {{ xdb.last_day("date2") }} AS last_day_feb
    , {{ xdb.last_day("date3") }} AS last_day_feb_leap
FROM inputs