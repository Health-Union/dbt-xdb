
-- depends_on: {{ ref('override_ref_test') }}

{{config({
    "tags":["exclude_bigquery", "exclude_bigquery_tests"],
    "pre-hook": [{"sql": "CREATE SCHEMA test_xdb_ref_schema_two;"}, 
                "{{ xdb.swap_schema('test_xdb_ref_schema_one', 'test_xdb_ref_schema_two') }}"],
    "post-hook": [{"sql": "DROP SCHEMA test_xdb_ref_schema_one CASCADE;
                           DROP SCHEMA test_xdb_ref_schema_two CASCADE;"}]})
}}

WITH test_objects_metadata AS (
    SELECT status FROM test_xdb_ref_schema_two.override_ref_test_model_view_based_on_table
    UNION ALL
    SELECT status FROM test_xdb_ref_schema_two.override_ref_test_model_view_based_on_view
)

SELECT
    SUM(status) AS reached_views_count
FROM test_objects_metadata