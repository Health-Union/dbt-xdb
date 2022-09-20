-- depends_on: {{ ref('clone_schema_test') }}

{{config({
    "tags":["exclude_bigquery", "exclude_bigquery_tests"],
    "post-hook": [{"sql": "DROP SCHEMA IF EXISTS clone_schema_one CASCADE;
                            DROP SCHEMA IF EXISTS clone_schema_two CASCADE;
                            DROP SCHEMA IF EXISTS clone_schema_three CASCADE;
                            DROP SCHEMA IF EXISTS clone_schema_four CASCADE;
                            DROP SCHEMA IF EXISTS clone_schema_five CASCADE;"}]})
}}

{% set fetch_test_tables %}
    SELECT
        LOWER(table_schema) AS schema_name
        , LOWER(table_name) AS object_name
    FROM information_schema.tables
    WHERE LOWER(table_schema) IN ('clone_schema_two','clone_schema_three','clone_schema_four','clone_schema_five')
{% endset %}

WITH all_tables_counts AS (
    {% for i in run_query(fetch_test_tables) -%}
        SELECT '{{i[0]}}' AS schema_name, '{{i[1]}}' AS object_name, COUNT(*) AS target_row_count FROM {{i[0]}}.{{i[1]}}
        {% if not loop.last  %}
        UNION ALL
        {% endif %}
    {%- endfor -%}
 )

 , unioned_counts AS (
    {% for i in run_query(fetch_test_tables) -%}
            SELECT '{{i[0]}}' AS schema_name, '{{i[1]}}' AS object_name, COUNT(*) AS unioned_row_count FROM
            (
                SELECT * FROM {{i[0]}}.{{i[1]}}
                UNION
                SELECT * FROM clone_schema_one.{{i[1]}}
            ) AS u
        {% if not loop.last  %}
        UNION ALL
        {% endif %}
    {%- endfor -%}
)

, table_stats AS (
    SELECT
        t.schema_name
        , t.object_name
        , t.target_row_count
        , u.unioned_row_count
        , t.target_row_count - u.unioned_row_count AS delta
    FROM all_tables_counts AS t
    LEFT JOIN
    unioned_counts AS u
    ON t.schema_name = u.schema_name
        AND t.object_name = u.object_name
)

SELECT *
FROM table_stats