{{config({
    "tags":["exclude_bigquery", "exclude_bigquery_tests"],
    "pre-hook": [{"sql": "DROP SCHEMA IF EXISTS clone_schema_one CASCADE;
                          CREATE SCHEMA clone_schema_one;
                          CREATE TABLE clone_schema_one.table_1 AS select * from (select 1 AS status
                          UNION ALL select 2 AS status) AS a;
                          CREATE TABLE clone_schema_one.table_2 AS select * from (select 1 AS status
                          UNION ALL select 2 AS status UNION ALL select 3 AS status) AS a;
                          COMMENT ON TABLE clone_schema_one.table_2 IS 'incremental';
                          CREATE SEQUENCE clone_schema_one.sequence_1 START WITH 2 INCREMENT BY 5;
                          CREATE SEQUENCE clone_schema_one.sequence_2;
                          COMMENT ON SEQUENCE clone_schema_one.sequence_2 IS 'incremental';
                          CREATE VIEW clone_schema_one.view_1 AS select 1 AS status;
                          CREATE VIEW clone_schema_one.view_2 AS select 1 AS status;
                          COMMENT ON VIEW clone_schema_one.view_2 IS 'incremental';

                            {%- if target.type == 'postgres' -%} 
                                
                                CREATE OR REPLACE FUNCTION clone_schema_one.test_func_1(integer, integer)
                                RETURNS integer
                                AS 'select $1 + $2;'
                                LANGUAGE SQL
                                IMMUTABLE
                                RETURNS NULL ON NULL INPUT;
                                
                                CREATE OR REPLACE FUNCTION clone_schema_one.test_func_2(integer, integer)
                                RETURNS integer
                                AS 'select $1 + $2;'
                                LANGUAGE SQL
                                IMMUTABLE
                                RETURNS NULL ON NULL INPUT;
                                COMMENT ON FUNCTION clone_schema_one.test_func_2 IS 'incremental';

                            {%- elif target.type == 'snowflake' -%}
                                CREATE FUNCTION clone_schema_one.test_func_1 (A number, B number)
                                RETURNS NUMBER
                                AS 'A * B';

                                CREATE FUNCTION clone_schema_one.test_func_2 (A number, B number)
                                RETURNS NUMBER
                                COMMENT='incremental'
                                AS 'A * B';

                                {% endif %}

                          DROP SCHEMA IF EXISTS clone_schema_two CASCADE;
                          CREATE SCHEMA clone_schema_two;
                          CREATE TABLE clone_schema_two.table_3 AS select 2 AS status;
                          CREATE VIEW clone_schema_two.view_3 AS select 2 AS status;
                          CREATE SEQUENCE clone_schema_two.sequence_3;

                          DROP SCHEMA IF EXISTS clone_schema_three CASCADE;
                          CREATE SCHEMA clone_schema_three;
                          CREATE TABLE clone_schema_three.table_4 AS select 2 AS status;
                          CREATE VIEW clone_schema_three.view_4 AS select 2 AS status;
                          CREATE SEQUENCE clone_schema_three.sequence_4;

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

{#/*
    This model shows how many deltas in tables/views/sequences/functions were found
    after triggering of test runs of `clone_schema()` macro.
*/#}

WITH all_objects_metadata AS (
        SELECT
        LOWER(table_type) AS object_type
        , LOWER(table_schema) AS schema_name
        , LOWER(table_name) AS object_name
        {%- if target.type == 'snowflake' -%}
        , COALESCE(comment, '') AS comment
        , 1 AS id
        {%- else -%}
        , '' AS comment
        , CONCAT_WS('.', table_schema, table_name)::regclass::oid AS id
        {%- endif %}
    FROM information_schema.tables
    WHERE LOWER(table_schema) IN ('clone_schema_one','clone_schema_two','clone_schema_three','clone_schema_four','clone_schema_five')
    UNION ALL
    SELECT
        'sequence' AS object_type
        , LOWER(sequence_schema) AS schema_name
        , LOWER(sequence_name) AS object_name
        {%- if target.type == 'snowflake' -%}
        , COALESCE(comment, '') AS comment
        , 1 AS id
        {%- else -%}
        , '' AS comment
        , CONCAT_WS('.', sequence_schema, sequence_name)::regclass::oid AS id
        {%- endif %}
    FROM information_schema.sequences
    WHERE LOWER(sequence_schema) IN ('clone_schema_one','clone_schema_two','clone_schema_three','clone_schema_four','clone_schema_five')
    UNION ALL

{% if target.type == 'postgres' -%}
    SELECT
        'function' AS object_type
        , n.nspname AS schema_name
        , p.proname AS object_name
        , '' AS comment
        , n.oid AS id
    FROM pg_proc p
    LEFT JOIN pg_namespace n 
        ON p.pronamespace = n.oid
    WHERE n.nspname IN ('clone_schema_one','clone_schema_two','clone_schema_three','clone_schema_four','clone_schema_five')

{% elif target.type == 'snowflake' -%}
    SELECT
        'function' AS object_type
        , LOWER(function_schema) AS schema_name
        , LOWER(function_name) AS object_name
        , COALESCE(comment, '') AS comment
        , 1 AS id
    FROM information_schema.functions
    WHERE LOWER(function_schema) IN ('clone_schema_one','clone_schema_two','clone_schema_three','clone_schema_four','clone_schema_five')
     {% endif %}
)

{%- if target.type == 'postgres' -%}
, all_objects_metadata_ext AS (
    SELECT
        object_type
        , schema_name
        , object_name
        , CASE WHEN description IS NOT null THEN description ELSE comment END AS comment
    FROM all_objects_metadata a
    LEFT JOIN
    pg_catalog.pg_description AS pgc
        ON a.id = pgc.objoid
)
{%- endif %}

, etalon_objects_metadata AS (
    SELECT *
        , 1 AS etalon_object_indicator
    FROM
    {% if target.type == 'postgres' -%}
    all_objects_metadata_ext
    {% else -%}
    all_objects_metadata
    {% endif -%}
    WHERE LOWER(schema_name) = 'clone_schema_one'
)

, target_objects_metadata AS (
    SELECT *
    FROM
    {% if target.type == 'postgres' -%}
    all_objects_metadata_ext
    {% else -%}
    all_objects_metadata
    {% endif -%}
    WHERE LOWER(schema_name) <> 'clone_schema_one'
)

, etalon_objects_stats AS (
    SELECT
        object_type
        , comment
        , CASE WHEN comment = '' THEN 0 ELSE 1 END AS tag_flag
        , SUM(etalon_object_indicator) AS count_etalon_obj
    FROM etalon_objects_metadata
    GROUP BY 1, 2, 3
)

, target_objects_stats AS (
    SELECT
        a.schema_name
        , a.object_type
        , CASE WHEN a.comment = '' THEN 0 ELSE 1 END AS tag_flag
        , SUM(COALESCE(b.etalon_object_indicator,0)) AS count_target_obj
    FROM
    target_objects_metadata AS a
    LEFT JOIN
    etalon_objects_metadata AS b
    ON a.object_type = b.object_type
        AND a.object_name = b.object_name
        AND a.comment = b.comment
    GROUP BY 1, 2, 3
)

, lead_table AS (
    SELECT 
        schema_name
        , TRIM({{ xdb.split_to_table_values("types") }}, ' ') AS object_type
        , TRIM({{ xdb.split_to_table_values("tags") }}, ' ')::integer AS tag_flag
    FROM (
        SELECT 'clone_schema_two' AS schema_name, 'sequence,base table,view,function' AS object_type, '0,1' AS tag_flag
        UNION ALL
        SELECT 'clone_schema_three' AS schema_name, 'sequence,base table,view,function' AS object_type, '0,1' AS tag_flag
        UNION ALL
        SELECT 'clone_schema_four' AS schema_name, 'sequence,base table,view,function' AS object_type, '0,1' AS tag_flag
        UNION ALL
        SELECT 'clone_schema_five' AS schema_name, 'sequence,base table,view,function' AS object_type, '0,1' AS tag_flag
    ) AS a
    , {{ xdb.split_to_table('a.object_type', ',') }} AS types
    , {{ xdb.split_to_table('a.tag_flag', ',') }} AS tags 
)

, joined_data AS (
    SELECT
        lead.*
        , COALESCE(target.count_target_obj, 0) AS count_target_obj
        , COALESCE(etalon.count_etalon_obj, 0) AS count_etalon_obj
        , COALESCE(etalon.count_etalon_obj, 0) - COALESCE(target.count_target_obj, 0) AS delta
    FROM lead_table AS lead
    LEFT JOIN
    target_objects_stats as target
    ON lead.schema_name = target.schema_name
        AND lead.object_type = target.object_type
        AND lead.tag_flag = target.tag_flag
    LEFT JOIN
    etalon_objects_stats as etalon
    ON lead.object_type = etalon.object_type
        AND lead.tag_flag = etalon.tag_flag
)

, deltas AS (
    SELECT
        schema_name
        , object_type
        , tag_flag
        , count(*) AS object_deltas_count
    FROM joined_data
    WHERE NOT (
            schema_name IN ('clone_schema_three', 'clone_schema_five')
            AND (tag_flag = 0
                OR
                (object_type in ('view','function')
                    AND tag_flag = 1)))
        AND delta <> 0
    GROUP BY 1, 2, 3
)

, final_stats AS (
    SELECT lead.schema_name
        , lead.object_type
        , SUM(CASE WHEN lead.tag_flag = 1 THEN COALESCE(deltas.object_deltas_count, 0) ELSE 0 END) AS tagged_object_deltas_count
        , SUM(CASE WHEN lead.tag_flag = 0 THEN COALESCE(deltas.object_deltas_count, 0) ELSE 0 END) AS untagged_object_deltas_count
    FROM lead_table AS lead
    LEFT JOIN
    deltas
    ON lead.schema_name = deltas.schema_name
        AND lead.object_type = deltas.object_type
        AND lead.tag_flag = deltas.tag_flag
    GROUP BY 1, 2
)

SELECT *
FROM final_stats
{%if target.type == 'snowflake' -%}
{% endif %}