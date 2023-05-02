WITH selected_two_first_tests AS (
    SELECT test_name
    FROM (VALUES ('test_1'), ('test_2'), ('test3')) AS tests (test_name)
    WHERE test_name {{ xdb.like_any(patterns=('test\\_1', 'test\\_2')) }}
)

SELECT test_name
FROM selected_two_first_tests
