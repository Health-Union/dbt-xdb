{{ config({"tags":["exclude_bigquery", "exclude_bigquery_tests"]}) }}
WITH
test_data AS (
    SELECT
        'A' AS part
        , '2020-01-01'::timestamp AS ts
        , 'cat' AS animal
        , 123 AS num
    UNION ALL
    SELECT
        'A' AS part
        , '2020-01-02'::timestamp AS ts
        , NULL AS animal
        , 456 AS num 
    UNION ALL
    SELECT
        'A' AS part
        , '2020-01-03'::timestamp AS ts
        , 'dog' AS animal
        , 789 AS num
    UNION ALL
    SELECT
        'B' AS part
        , '2020-01-01'::timestamp AS ts
        , 'cat' AS animal
        , 123 AS num
    UNION ALL
    SELECT
        'B' AS part
        , '2020-01-02'::timestamp AS ts
        , 'dog' AS animal
        , 789 AS num
    UNION ALL
    SELECT
        'C' AS part
        , '2020-01-01'::timestamp AS ts
        , 'coyote' AS animal
        , 789 AS num
)

SELECT
    part
    , ts
    , animal
    , {{ xdb.last_value('animal', 'text', 'part', 'ts') }} AS last_string_value_asc
    , {{ xdb.last_value('animal', 'text', 'part', 'ts DESC') }} AS last_string_value_desc
    , {{ xdb.last_value('num', 'numeric', 'part', 'ts') }} AS last_numeric_value
FROM
   test_data
