WITH starter_values AS (
	SELECT 0 AS index_column, 'a' AS val
	UNION ALL 
	SELECT 0 AS index_column, 'b' AS val
	UNION ALL 
	SELECT 0 AS index_column, 'c' AS val
)

, array_agg_values AS (
    SELECT index_column
    , ARRAY_AGG(val) AS array_values
    FROM starter_values
    GROUP BY 1
)

SELECT array_values[ {{xdb.array_index(0) }}] AS value_col
FROM array_agg_values