{{config({
    "pre-hook": [{"sql": "CREATE SCHEMA ref_schema_one;"}],
    "materialized": "table",
    "schema": "ref_schema_one"})
}}

SELECT 1 AS status