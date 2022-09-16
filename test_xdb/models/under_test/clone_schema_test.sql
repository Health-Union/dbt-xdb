{{config({
    "tags":["exclude_bigquery", "exclude_bigquery_tests"],
    "pre-hook": [{"sql": "DROP SCHEMA IF EXISTS clone_schema_one CASCADE;
                          CREATE SCHEMA clone_schema_one;
                          CREATE TABLE clone_schema_one.table_1 AS select 1 AS status;
                          CREATE TABLE clone_schema_one.table_2 AS select 1 AS status;
                          COMMENT ON TABLE clone_schema_one.table_2 IS 'incremental';
                          CREATE SEQUENCE clone_schema_one.sequence_1;
                          CREATE SEQUENCE clone_schema_one.sequence_2;
                          COMMENT ON SEQUENCE clone_schema_one.sequence_2 IS 'incremental';
                          CREATE VIEW clone_schema_one.view_1 AS select 1 AS status;
                          CREATE VIEW clone_schema_one.view_2 AS select 1 AS status;
                          COMMENT ON VIEW clone_schema_one.view_2 IS 'incremental';

                          DROP SCHEMA IF EXISTS clone_schema_two CASCADE;
                          CREATE SCHEMA clone_schema_two;
                          CREATE TABLE clone_schema_two.table_3 AS select 2 AS status;
                          CREATE VIEW clone_schema_two.view_3 AS select 2 AS status;
                          CREATE SEQUENCE clone_schema_two.sequence_3;

                          DROP SCHEMA IF EXISTS clone_schema_three CASCADE;
                          CREATE SCHEMA clone_schema_three;
                          CREATE TABLE clone_schema_two.table_4 AS select 2 AS status;
                          CREATE VIEW clone_schema_two.view_4 AS select 2 AS status;
                          CREATE SEQUENCE clone_schema_two.sequence_4;

                          DROP SCHEMA IF EXISTS clone_schema_four CASCADE;
                          DROP SCHEMA IF EXISTS clone_schema_five CASCADE;"
                          },
                "{{ xdb.clone_schema('clone_schema_one', 'clone_schema_two') }}",
                "{{ xdb.clone_schema('clone_schema_one', 'clone_schema_three', 'incremental') }}",
                "{{ xdb.clone_schema('clone_schema_one', 'clone_schema_four') }}",
                "{{ xdb.clone_schema('clone_schema_one', 'clone_schema_five', 'incremental') }}"],
    "post-hook": [{"sql": "DROP SCHEMA IF EXISTS clone_schema_one CASCADE;
                           DROP SCHEMA IF EXISTS clone_schema_two CASCADE;
                           DROP SCHEMA IF EXISTS clone_schema_three CASCADE;
                           DROP SCHEMA IF EXISTS clone_schema_four CASCADE;
                           DROP SCHEMA IF EXISTS clone_schema_five CASCADE;"}]})
}}

WITH test_objects_metadata AS (
    SELECT
        LOWER(table_type) AS object_type
        , table_schema AS schema_name
        , table_name AS object_name
    FROM information_schema.tables
    WHERE LOWER(table_schema) IN ('clone_schema_one','clone_schema_two','clone_schema_three','clone_schema_four','clone_schema_five')
    UNION ALL
    SELECT
        'sequence' AS object_type
        , sequence_schema AS schema_name
        , sequence_name AS object_name
    FROM information_schema.sequences
    WHERE LOWER(sequence_schema) IN ('clone_schema_one','clone_schema_two','clone_schema_three','clone_schema_four','clone_schema_five')
)

SELECT *
FROM test_objects_metadata