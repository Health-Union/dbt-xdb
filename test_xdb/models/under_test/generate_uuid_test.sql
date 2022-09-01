{{ config({
    "tags":["exclude_bigquery", "exclude_bigquery_tests"],
    "pre-hook": [{"sql": '{%- if target.type == "postgres" -%}
                          CREATE EXTENSION IF NOT EXISTS "uuid-ossp";
                          {%- endif -%}'}],
    "post-hook": [{"sql": '{%- if target.type == "postgres" -%}
                          DROP EXTENSION "uuid-ossp";
                          {%- endif -%}'}]})
}}

WITH uuids AS (
    SELECT {{xdb.generate_uuid()}} AS uuid_varchar
    UNION ALL
    SELECT {{xdb.generate_uuid()}} AS uuid_varchar
    UNION ALL
    SELECT {{xdb.generate_uuid()}} AS uuid_varchar
    UNION ALL
    SELECT {{xdb.generate_uuid()}} AS uuid_varchar
    UNION ALL
    SELECT {{xdb.generate_uuid()}} AS uuid_varchar
    UNION ALL
    SELECT {{xdb.generate_uuid()}} AS uuid_varchar
    UNION ALL
    SELECT {{xdb.generate_uuid()}} AS uuid_varchar
    UNION ALL
    SELECT {{xdb.generate_uuid()}} AS uuid_varchar
    UNION ALL
    SELECT {{xdb.generate_uuid()}} AS uuid_varchar
)

SELECT
    uuid_varchar
    , LENGTH(REPLACE(uuid_varchar, '-', '')) AS uuid_length
    , REGEXP_REPLACE(uuid_varchar, '[0-9A-Fa-f]{8}(-[0-9A-Fa-f]{4}){3}-[0-9A-Fa-f]{12}', '00000000-0000-0000-0000-000000000000') AS uuid_regex
FROM uuids