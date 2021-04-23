{{ config({"tags":["exclude_bigquery", "exclude_bigquery_tests"]}) }}

WITH starter_values AS (
	SELECT 0 AS index_column, 'a' AS val
	UNION ALL 
	SELECT 0 AS index_column, 'b' AS val
	UNION ALL 
	SELECT 0 AS index_column, 'c' AS val
    UNION ALL
    SELECT 1 AS index_cloumn, 'd' AS val
    UNION ALL
    SELECT 1 AS index_cloumn, 'e' AS val
    UNION ALL
    SELECT 1 AS index_cloumn, 'f' AS val
    UNION ALL
    SELECT 2 AS index_cloumn, 'g' AS val
    UNION ALL
    SELECT 2 AS index_cloumn, 'h' AS val
    UNION ALL
    SELECT 2 AS index_cloumn, 'i' AS val

)

, array_agg_values AS (
    SELECT index_column
    , ARRAY_AGG(val) AS array_values
    FROM starter_values
    GROUP BY 1
)

SELECT index_column AS value_col
FROM array_agg_values
WHERE {{ xdb.array_contains('array_values', "'e'") }}