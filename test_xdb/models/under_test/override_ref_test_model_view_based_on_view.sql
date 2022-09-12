{{config({
    "pre-hook": [{"sql": "CREATE SCHEMA IF NOT EXISTS ref_schema_one;"}],
    "materialized": "view",
    "schema": "ref_schema_one"})
}}

SELECT * FROM {{ xdb.override_ref('override_ref_test_model_view_based_on_table') }}