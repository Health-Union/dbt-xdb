--depends_on: {{ ref('clone_schema_tables_data_equality_test') }}

{{config({
    "tags":["exclude_bigquery", "exclude_bigquery_tests"],
    "pre-hook": [{"sql": "DROP SCHEMA IF EXISTS clone_schema_tables_metadata_one CASCADE;
                          CREATE SCHEMA clone_schema_tables_metadata_one;
                          CREATE TABLE clone_schema_tables_metadata_one.table_1 AS select * from (select 1 AS status
                          UNION ALL select 2 AS status) AS a;
                          CREATE TABLE clone_schema_tables_metadata_one.table_2 AS select * from (select 1 AS status
                          UNION ALL select 2 AS status UNION ALL select 3 AS status) AS a;
                          COMMENT ON TABLE clone_schema_tables_metadata_one.table_2 IS 'incremental';
                          CREATE VIEW clone_schema_tables_metadata_one.view_1 AS select 1 AS status;
                          CREATE VIEW clone_schema_tables_metadata_one.view_2 AS select 1 AS status;
                          COMMENT ON VIEW clone_schema_tables_metadata_one.view_2 IS 'incremental';

                          DROP SCHEMA IF EXISTS clone_schema_tables_metadata_two CASCADE;
                          CREATE SCHEMA clone_schema_tables_metadata_two;
                          CREATE TABLE clone_schema_tables_metadata_two.table_3 AS select 2 AS status;
                          CREATE VIEW clone_schema_tables_metadata_two.view_3 AS select 2 AS status;

                          DROP SCHEMA IF EXISTS clone_schema_tables_metadata_three CASCADE;
                          CREATE SCHEMA clone_schema_tables_metadata_three;
                          CREATE TABLE clone_schema_tables_metadata_three.table_4 AS select 2 AS status;
                          CREATE VIEW clone_schema_tables_metadata_three.view_4 AS select 2 AS status;

                          DROP SCHEMA IF EXISTS clone_schema_tables_metadata_four CASCADE;
                          DROP SCHEMA IF EXISTS clone_schema_tables_metadata_five CASCADE;"
                          },
                "{{ xdb.clone_schema('clone_schema_tables_metadata_one', 'clone_schema_tables_metadata_two') }}",
                "{{ xdb.clone_schema('clone_schema_tables_metadata_one', 'clone_schema_tables_metadata_three', 'incremental') }}",
                "{{ xdb.clone_schema('clone_schema_tables_metadata_one', 'clone_schema_tables_metadata_four') }}",
                "{{ xdb.clone_schema('clone_schema_tables_metadata_one', 'clone_schema_tables_metadata_five', 'incremental') }}"],
    "post-hook": [{"sql": "DROP SCHEMA IF EXISTS clone_schema_tables_metadata_one CASCADE;
                           DROP SCHEMA IF EXISTS clone_schema_tables_metadata_two CASCADE;
                           DROP SCHEMA IF EXISTS clone_schema_tables_metadata_three CASCADE;
                           DROP SCHEMA IF EXISTS clone_schema_tables_metadata_four CASCADE;
                           DROP SCHEMA IF EXISTS clone_schema_tables_metadata_five CASCADE;"}]})
}}

{#/*
    This model shows lists of metadata fields with deltas between original and copied tables/views
    in test schemas after triggering of test runs of `clone_schema()` macro.
*/#}

{%- if target.type != 'snowflake' -%}
    {% set database = 'testxdb'%}
{%- endif %}

{% set columns = adapter.get_columns_in_relation(
                adapter.get_relation(database=database, 
                schema='information_schema',
                identifier='tables')) %}

WITH target_tables_metadata AS (
    SELECT
    {%- for column in columns -%}
        {%- if loop.first %}
        {{column.name.lower()}} AS {{column.name.lower()}}_target
            {%- else %}
        , {{column.name.lower()}} AS {{column.name.lower()}}_target
        {%- endif %}
    {%- endfor %}
    FROM information_schema.tables
    WHERE LOWER(table_schema) IN ('clone_schema_tables_metadata_two','clone_schema_tables_metadata_three','clone_schema_tables_metadata_four','clone_schema_tables_metadata_five')
)

, etalon_tables_metadata AS (
    SELECT
    {%- for column in columns -%}
        {%- if loop.first %}
        {{column.name.lower()}} AS {{column.name.lower()}}_etalon
            {%- else %}
        , {{column.name.lower()}} AS {{column.name.lower()}}_etalon
        {%- endif %}
    {%- endfor %}
    FROM information_schema.tables
    WHERE LOWER(table_schema) = 'clone_schema_tables_metadata_one'
)

, joined_tables_metadata AS (
    SELECT
        a.table_schema_target AS table_schema
        , a.table_name_target AS table_name
    {%- for column in columns -%}
        {%- if column.name.lower() not in ['table_name','table_catalog','table_schema']%}
        , CASE WHEN COALESCE({{column.name.lower()}}_etalon::varchar, '') <> COALESCE({{column.name.lower()}}_target::varchar, '') THEN '{{column.name.lower()}}' ELSE '' END AS {{column.name.lower()}}_delta
        {%- endif %}
    {%- endfor %}
    FROM target_tables_metadata AS a
    LEFT JOIN
    etalon_tables_metadata AS b
    ON a.table_name_target = b.table_name_etalon
)

, collected_metadata AS (
    SELECT
        table_schema
        , table_name
    {%- if target.type == 'snowflake' -%}
        , ARRAY_CONSTRUCT('none'
                {%- for column in columns -%}
                    {%- if column.name.lower() not in ['table_name','table_catalog','table_schema']%}
                    , {{column.name.lower()}}_delta
                    {%- endif %}
                {%- endfor %}
        ) AS not_mached_metadata_fields
    {%- else -%}
        , array_remove(ARRAY['none'
                {%- for column in columns -%}
                    {%- if column.name.lower() not in ['table_name','table_catalog','table_schema']%}
                    , {{column.name.lower()}}_delta
                    {%- endif %}
                {%- endfor %}
            ],'')::varchar AS not_mached_metadata_fields
    {%- endif %}
    FROM joined_tables_metadata
)

{%- if target.type == 'snowflake' -%}
, collected_metadata_snowflake AS (
    SELECT
        LOWER(table_schema) AS table_schema
        , LOWER(table_name) AS table_name
        , ARRAY_AGG(value)::varchar AS not_mached_metadata_fields
    FROM collected_metadata, 
    LATERAL FLATTEN(not_mached_metadata_fields)
    WHERE VALUE NOT IN ('','created','last_altered')
    GROUP BY 1, 2
)
{%- endif %}

SELECT *
FROM 
{% if target.type == 'snowflake' -%}
collected_metadata_snowflake
{%- else %}
collected_metadata
{%- endif %}