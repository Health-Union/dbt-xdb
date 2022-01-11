{{ config(tags=["exclude_bigquery","exclude_bigquery_tests"]) }}

WITH
source_data AS (
    SELECT
        'A,B,C,D,E' AS string_to_split_into_parts
)

SELECT
    {{ xdb.split_part('string_to_split_into_parts', "','", 2) }} AS return_b_positive
    , {{ xdb.split_part('string_to_split_into_parts', "','", -2) }} AS return_d_negative
FROM
    source_data
