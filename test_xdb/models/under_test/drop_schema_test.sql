{{config({
    "tags":["exclude_bigquery", "exclude_bigquery_tests"],
    "pre-hook": [{"sql": "CREATE SCHEMA drop_schema_test_schema;
                          CREATE TABLE drop_schema_test_schema.table_1 AS select 1 AS column_1;
                          CREATE VIEW drop_schema_test_schema.view_1 AS select 1 AS column_1;
                          CREATE SEQUENCE drop_schema_test_schema.sequence_1;"
                          }, 
                "{{ xdb.drop_schema('drop_schema_test_schema') }}"]})
}}

WITH lead_table AS (
    SELECT 'drop_schema_test_schema' AS schema_name
)

, schema_presence AS (
    SELECT
        LOWER(schema_name) AS schema_name
        , 1 AS schema_presence_flag
    FROM information_schema.schemata
    WHERE schema_name = 'drop_schema_test_schema'
)

, tables_count AS (
    SELECT
        LOWER(table_schema) AS schema_name
        , COUNT(*) AS schema_tables_count
    FROM information_schema.tables
    WHERE table_schema = 'drop_schema_test_schema'
    GROUP BY 1
)

, sequences_count AS (
    SELECT
        LOWER(sequence_schema) AS schema_name
        , COUNT(*) AS schema_sequences_count
    FROM information_schema.sequences
    WHERE sequence_schema = 'drop_schema_test_schema'
    GROUP BY 1
)

, joined_data AS (
    SELECT
        a.schema_name
        , CASE WHEN b.schema_presence_flag = 1 THEN true ELSE false END AS schema_presence_flag
        , CASE WHEN c.schema_tables_count IS NOT NULL THEN true ELSE false END AS schema_tables_presence_flag
        , CASE WHEN d.schema_sequences_count IS NOT NULL THEN true ELSE false END AS schema_sequences_presence_flag
    FROM lead_table AS a
    LEFT JOIN
    schema_presence AS b
        ON a.schema_name = b.schema_name
    LEFT JOIN
    tables_count AS c
        ON a.schema_name = c.schema_name
    LEFT JOIN
    sequences_count AS d
        ON a.schema_name = d.schema_name
)

SELECT *
FROM joined_data