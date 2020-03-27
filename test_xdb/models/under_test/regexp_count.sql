WITH
source_data AS (
    SELECT
        'abba is a great band' AS false_statement
)
   
SELECT
    {{xdb.regexp_count(false_statement, 'b')}} AS finds_three
FROM
    source_data
