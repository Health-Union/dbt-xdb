{{ config(tags=["bigquery", "postgres","snowflake","redshift"]) }}

WITH
values_of_things AS (
	SELECT 'apple' AS value_col
	UNION ALL 
	SELECT 'tractor' AS value_col
	UNION ALL 
	SELECT 'zebra' AS value_col
)

SELECT 
    {{ xdb.aggregate_strings('value_col', "','") }} AS value_col
FROM
    values_of_things
