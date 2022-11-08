--depends_on: {{ ref('clone_schema_grants_test') }}

{{config({
    "tags":["exclude_bigquery", "exclude_bigquery_tests"],
    "pre-hook": [{"sql": "CREATE SCHEMA schema_one;
                          CREATE TABLE schema_one.table_1 AS select 1 AS column_1;
                          CREATE VIEW schema_one.view_1 AS select 1 AS column_1;
                          CREATE SEQUENCE schema_one.sequence_1;
                          CREATE SCHEMA schema_two;
                          CREATE TABLE schema_two.table_2 AS select 2 AS column_2;
                          CREATE VIEW schema_two.view_2 AS select 2 AS column_2;
                          CREATE SEQUENCE schema_two.sequence_2;"
                          }, 
                "{{ xdb.swap_schema('schema_one', 'schema_two') }}"],
    "post-hook": [{"sql": "DROP SCHEMA schema_one CASCADE;
                           DROP SCHEMA schema_two CASCADE;"}]})
}}

WITH test_objects_metadata AS (
    SELECT
        LOWER(table_type) AS object_type
        , table_schema AS schema_name
        , table_name AS object_name
    FROM information_schema.tables
    WHERE table_schema IN ('schema_one','schema_two')
    UNION ALL
    SELECT
        'sequence' AS object_type
        , sequence_schema AS schema_name
        , sequence_name AS object_name
    FROM information_schema.sequences
    WHERE sequence_schema IN ('schema_one','schema_two')
)

SELECT
    object_type
    , MAX(CASE WHEN (schema_name='schema_one') THEN object_name ELSE NULL END) AS schema_one
    , MAX(CASE WHEN (schema_name='schema_two') THEN object_name ELSE NULL END) AS schema_two
FROM test_objects_metadata
GROUP BY 1