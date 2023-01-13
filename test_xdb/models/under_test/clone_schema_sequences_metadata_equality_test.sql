--depends_on: {{ ref('clone_schema_tables_metadata_equality_test') }}

{{config({
    "tags":["exclude_bigquery", "exclude_bigquery_tests"],
    "pre-hook": [{"sql": "DROP SCHEMA IF EXISTS clone_schema_sequences_metadata_one CASCADE;
                          CREATE SCHEMA clone_schema_sequences_metadata_one;
                          CREATE SEQUENCE clone_schema_sequences_metadata_one.sequence_1 START WITH 2 INCREMENT BY 5;
                          CREATE SEQUENCE clone_schema_sequences_metadata_one.sequence_2;
                          COMMENT ON SEQUENCE clone_schema_sequences_metadata_one.sequence_2 IS 'incremental';

                          DROP SCHEMA IF EXISTS clone_schema_sequences_metadata_two CASCADE;
                          CREATE SCHEMA clone_schema_sequences_metadata_two;
                          CREATE SEQUENCE clone_schema_sequences_metadata_two.sequence_3;

                          DROP SCHEMA IF EXISTS clone_schema_sequences_metadata_three CASCADE;
                          CREATE SCHEMA clone_schema_sequences_metadata_three;
                          CREATE SEQUENCE clone_schema_sequences_metadata_three.sequence_4;

                          DROP SCHEMA IF EXISTS clone_schema_sequences_metadata_four CASCADE;
                          DROP SCHEMA IF EXISTS clone_schema_sequences_metadata_five CASCADE;"
                          },
                "{{ xdb.clone_schema('clone_schema_sequences_metadata_one', 'clone_schema_sequences_metadata_two') }}",
                "{{ xdb.clone_schema('clone_schema_sequences_metadata_one', 'clone_schema_sequences_metadata_three', 'incremental') }}",
                "{{ xdb.clone_schema('clone_schema_sequences_metadata_one', 'clone_schema_sequences_metadata_four') }}",
                "{{ xdb.clone_schema('clone_schema_sequences_metadata_one', 'clone_schema_sequences_metadata_five', 'incremental') }}"],
    "post-hook": [{"sql": "DROP SCHEMA IF EXISTS clone_schema_sequences_metadata_one CASCADE;
                           DROP SCHEMA IF EXISTS clone_schema_sequences_metadata_two CASCADE;
                           DROP SCHEMA IF EXISTS clone_schema_sequences_metadata_three CASCADE;
                           DROP SCHEMA IF EXISTS clone_schema_sequences_metadata_four CASCADE;
                           DROP SCHEMA IF EXISTS clone_schema_sequences_metadata_five CASCADE;"}]})
}}

{#/*
    This model shows lists of metadata fields with deltas between original and copied sequences
    in test schemas after triggering of test runs of `clone_schema()` macro.
*/#}

{%- if target.type != 'snowflake' -%}
    {% set database = 'testxdb'%}
{%- endif %}

{% set columns = adapter.get_columns_in_relation(
                adapter.get_relation(database=database, 
                schema='information_schema',
                identifier='sequences')) %}

WITH target_sequences_metadata AS (
    SELECT
    {%- for column in columns -%}
        {%- if loop.first %}
        "{{xdb._fold(column.name.lower())}}" AS {{column.name.lower()}}_target
            {%- else %}
        , "{{xdb._fold(column.name.lower())}}" AS {{column.name.lower()}}_target
        {%- endif %}
    {%- endfor %}
    FROM information_schema.sequences
    WHERE LOWER(sequence_schema) IN ('clone_schema_sequences_metadata_two','clone_schema_sequences_metadata_three','clone_schema_sequences_metadata_four','clone_schema_sequences_metadata_five')
)

, etalon_sequences_metadata AS (
    SELECT
    {%- for column in columns -%}
        {%- if loop.first %}
        "{{xdb._fold(column.name.lower())}}" AS {{column.name.lower()}}_etalon
            {%- else %}
        , "{{xdb._fold(column.name.lower())}}" AS {{column.name.lower()}}_etalon
        {%- endif %}
    {%- endfor %}
    FROM information_schema.sequences
    WHERE LOWER(sequence_schema) = 'clone_schema_sequences_metadata_one'
)

, joined_sequences_metadata AS (
    SELECT
        a.sequence_schema_target AS sequence_schema
        , a.sequence_name_target AS sequence_name
    {%- for column in columns -%}
        {%- if column.name.lower() not in ['sequence_name','sequence_catalog','sequence_schema']%}
        , CASE WHEN COALESCE({{column.name.lower()}}_etalon::varchar, '') <> COALESCE({{column.name.lower()}}_target::varchar, '') THEN '{{column.name.lower()}}' ELSE '' END AS {{column.name.lower()}}_delta
        {%- endif %}
    {%- endfor %}
    FROM target_sequences_metadata AS a
    LEFT JOIN
    etalon_sequences_metadata AS b
    ON a.sequence_name_target = b.sequence_name_etalon
)

, collected_metadata AS (
    SELECT
        sequence_schema
        , sequence_name
    {%- if target.type == 'snowflake' -%}
        , ARRAY_CONSTRUCT('none'
                {%- for column in columns -%}
                    {%- if column.name.lower() not in ['sequence_name','sequence_catalog','sequence_schema']%}
                    , {{column.name.lower()}}_delta
                    {%- endif %}
                {%- endfor %}
        ) AS not_mached_metadata_fields
    {%- else -%}
        , array_remove(ARRAY['none'
                {%- for column in columns -%}
                    {%- if column.name.lower() not in ['sequence_name','sequence_catalog','sequence_schema']%}
                    , {{column.name.lower()}}_delta
                    {%- endif %}
                {%- endfor %}
            ],'')::varchar AS not_mached_metadata_fields
    {%- endif %}
    FROM joined_sequences_metadata
)

{%- if target.type == 'snowflake' -%}
, collected_metadata_snowflake AS (
    SELECT
        LOWER(sequence_schema) AS sequence_schema
        , LOWER(sequence_name) AS sequence_name
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