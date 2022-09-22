--depends_on: {{ ref('clone_schema_test') }}

{{config({
    "tags":["exclude_bigquery", "exclude_bigquery_tests"],
    "pre-hook": [{"sql": "DROP SCHEMA IF EXISTS clone_schema_tables_data_one CASCADE;
                          CREATE SCHEMA clone_schema_tables_data_one;
                          CREATE TABLE clone_schema_tables_data_one.table_1 AS select * from (select 1 AS status
                          UNION ALL select 2 AS status) AS a;
                          CREATE TABLE clone_schema_tables_data_one.table_2 AS select * from (select 1 AS status
                          UNION ALL select 2 AS status UNION ALL select 3 AS status) AS a;
                          COMMENT ON TABLE clone_schema_tables_data_one.table_2 IS 'incremental';
                          CREATE VIEW clone_schema_tables_data_one.view_1 AS select 1 AS status;
                          CREATE VIEW clone_schema_tables_data_one.view_2 AS select 1 AS status;
                          COMMENT ON VIEW clone_schema_tables_data_one.view_2 IS 'incremental';

                          DROP SCHEMA IF EXISTS clone_schema_tables_data_two CASCADE;
                          CREATE SCHEMA clone_schema_tables_data_two;
                          CREATE TABLE clone_schema_tables_data_two.table_3 AS select 2 AS status;
                          CREATE VIEW clone_schema_tables_data_two.view_3 AS select 2 AS status;

                          DROP SCHEMA IF EXISTS clone_schema_tables_data_three CASCADE;
                          CREATE SCHEMA clone_schema_tables_data_three;
                          CREATE TABLE clone_schema_tables_data_three.table_4 AS select 2 AS status;
                          CREATE VIEW clone_schema_tables_data_three.view_4 AS select 2 AS status;

                          DROP SCHEMA IF EXISTS clone_schema_tables_data_four CASCADE;
                          DROP SCHEMA IF EXISTS clone_schema_tables_data_five CASCADE;"
                          },
                "{{ xdb.clone_schema('clone_schema_tables_data_one', 'clone_schema_tables_data_two') }}",
                "{{ xdb.clone_schema('clone_schema_tables_data_one', 'clone_schema_tables_data_three', 'incremental') }}",
                "{{ xdb.clone_schema('clone_schema_tables_data_one', 'clone_schema_tables_data_four') }}",
                "{{ xdb.clone_schema('clone_schema_tables_data_one', 'clone_schema_tables_data_five', 'incremental') }}"],
    "post-hook": [{"sql": "DROP SCHEMA IF EXISTS clone_schema_tables_data_one CASCADE;
                           DROP SCHEMA IF EXISTS clone_schema_tables_data_two CASCADE;
                           DROP SCHEMA IF EXISTS clone_schema_tables_data_three CASCADE;
                           DROP SCHEMA IF EXISTS clone_schema_tables_data_four CASCADE;
                           DROP SCHEMA IF EXISTS clone_schema_tables_data_five CASCADE;"}]})
}}

{% set test_tables = [('clone_schema_tables_data_two', 'table_1')
                      , ('clone_schema_tables_data_two', 'table_2')
                      , ('clone_schema_tables_data_two', 'view_1')
                      , ('clone_schema_tables_data_two', 'view_2') 
                      , ('clone_schema_tables_data_three', 'table_2')
                      , ('clone_schema_tables_data_four', 'table_1')
                      , ('clone_schema_tables_data_four', 'table_2')
                      , ('clone_schema_tables_data_four', 'view_1')
                      , ('clone_schema_tables_data_four', 'view_2') 
                      , ('clone_schema_tables_data_five', 'table_2')] %}

WITH all_tables_counts AS (
    {% for i in test_tables -%}
        SELECT '{{i[0]}}' AS table_schema, '{{i[1]}}' AS table_name, COUNT(*) AS target_row_count FROM {{i[0]}}.{{i[1]}}
        {% if not loop.last  %}
        UNION ALL
        {% endif %}
    {%- endfor -%}
 )

 , unioned_counts AS (
    {% for i in test_tables -%}
            SELECT '{{i[0]}}' AS table_schema, '{{i[1]}}' AS table_name, COUNT(*) AS unioned_row_count FROM
            (
                SELECT * FROM {{i[0]}}.{{i[1]}}
                UNION
                SELECT * FROM clone_schema_tables_data_one.{{i[1]}}
            ) AS u
        {% if not loop.last  %}
        UNION ALL
        {% endif %}
    {%- endfor -%}
)

, table_stats AS (
    SELECT
        t.table_schema
        , t.table_name
        , t.target_row_count
        , u.unioned_row_count
        , t.target_row_count - u.unioned_row_count AS not_matched_rows_count
    FROM all_tables_counts AS t
    LEFT JOIN
    unioned_counts AS u
    ON t.table_schema = u.table_schema
        AND t.table_name = u.table_name
)

SELECT *
FROM table_stats