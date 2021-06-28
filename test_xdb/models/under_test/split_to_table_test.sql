WITH
test_cte AS (
    SELECT 'Lorem ipsum dolor sit amet,' AS text_field
    UNION ALL
    SELECT 'ad augue eget.' AS text_field
    UNION ALL
    SELECT 'Dictumst blandit semper arcu,' AS text_field
)

SELECT {{ xdb.split_to_table_values("temp") }} AS value_field
FROM test_cte
, {{ xdb.split_to_table("test_cte.text_field", ' ' ) }} temp


