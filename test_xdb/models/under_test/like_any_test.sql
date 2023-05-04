WITH selected_two_first_tests AS (
{%- if target.type == 'postgres' -%}
    SELECT test_name
    FROM (VALUES ('test_1'), ('test_2'), ('test3')) AS tests (test_name)
    WHERE test_name {{ xdb.like_any(patterns=('test\\_1', 'test\\_2')) }}
{%- elif target.type == 'snowflake' -%}
    SELECT test_name
    FROM (VALUES ('test_1'), ('test_2'), ('test3')) AS tests (test_name)
    WHERE test_name {{ xdb.like_any(patterns=('test\\_1', 'test\\_2')) }}
    UNION
    SELECT test_name
    FROM (VALUES ('test_11'), ('test_22'), ('test33')) AS tests (test_name)
    WHERE test_name {{ xdb.like_any(patterns=('test^_11', 'test^_22'), escape='^') }}
{%- endif -%}
)

SELECT test_name
FROM selected_two_first_tests
