{{config({
    "tags":["exclude_bigquery", "exclude_bigquery_tests"],
    "pre-hook": [{"sql": "{%- if target.type == 'postgres' -%}
                                DROP SCHEMA IF EXISTS schema_one CASCADE;
                                DROP SCHEMA IF EXISTS schema_two CASCADE;
                                DROP USER IF EXISTS user_1;
                                DROP USER IF EXISTS user_2;
                                DROP ROLE IF EXISTS role_1;
                                DROP ROLE IF EXISTS role_2;
                                CREATE SCHEMA schema_one;
                                CREATE USER user_1;
                                CREATE ROLE role_1;
                                ALTER SCHEMA schema_one OWNER TO user_1;
                                GRANT USAGE ON SCHEMA schema_one TO role_1;
                                GRANT CREATE ON SCHEMA schema_one TO role_1;
                                CREATE SCHEMA schema_two;
                                CREATE USER user_2;
                                CREATE ROLE role_2;
                                ALTER SCHEMA schema_two OWNER TO user_2;
                                GRANT USAGE ON SCHEMA schema_two TO role_2;
                                GRANT CREATE ON SCHEMA schema_two TO role_2;
                          {%- elif target.type == 'snowflake' -%}
                                USE ROLE XDB_ROLE;
                                DROP SCHEMA IF EXISTS schema_one CASCADE;
                                DROP SCHEMA IF EXISTS schema_two CASCADE;
                                CREATE SCHEMA schema_one;
                                GRANT ALL PRIVILEGES ON SCHEMA schema_one TO XDB_ROLE;
                                CREATE SCHEMA schema_two;
                                GRANT OWNERSHIP ON SCHEMA schema_two TO PUBLIC REVOKE CURRENT GRANTS;
                                GRANT ALL PRIVILEGES ON SCHEMA schema_two TO PUBLIC;
                          {%- endif -%}"},
                "{%- if target.type == 'postgres' -%}
                    {{ xdb.clone_schema_grants('schema_one', 'schema_two') }}
                {%- elif target.type == 'snowflake' -%}
                    {% set schema_one_full = env_var('SNOWFLAKE_DATABASE') ~ '.' ~ 'schema_one' %}
                    {% set schema_two_full = env_var('SNOWFLAKE_DATABASE') ~ '.' ~ 'schema_two' %}
                    {% set database_one = env_var('SNOWFLAKE_DATABASE') %}
                    
                            {{ xdb.clone_schema_grants(schema_one_full, schema_two_full) }}

                    {% set scan_grants_schema_one %}
                        SHOW GRANTS ON SCHEMA {{schema_one_full}};
                    {% endset %}
                    {% do run_query(scan_grants_schema_one) %}

                    {% set scan_grants_schema_two %}
                        SHOW GRANTS ON SCHEMA {{schema_two_full}};
                    {% endset %}
                    {% do run_query(scan_grants_schema_two) %}

                    {% set sql %}
                    SET scan_query_id_schema_one = (
                        SELECT query_id
                        FROM TABLE({{database_one}}.INFORMATION_SCHEMA.QUERY_HISTORY())
                        WHERE query_text = 'SHOW GRANTS ON SCHEMA {{schema_one_full}};'
                        ORDER BY start_time DESC
                        LIMIT 1);
                    SET scan_query_id_schema_two = (
                        SELECT query_id
                        FROM TABLE({{database_one}}.INFORMATION_SCHEMA.QUERY_HISTORY())
                        WHERE query_text = 'SHOW GRANTS ON SCHEMA {{schema_two_full}};'
                        ORDER BY start_time DESC
                        LIMIT 1);
                    {% endset %}
                    {% do run_query(sql) %}
                {%- endif -%}"],
    "post-hook": [{"sql": "{%- if target.type == 'postgres' -%}
                                DROP SCHEMA schema_one CASCADE;
                                DROP SCHEMA schema_two CASCADE;
                                DROP USER user_1;
                                DROP USER user_2;
                                DROP ROLE role_1;
                                DROP ROLE role_2;
                           {%- elif target.type == 'snowflake' -%}
                                DROP SCHEMA schema_one CASCADE;
                                DROP SCHEMA schema_two CASCADE;
                           {%- endif -%}"}]})
}}

WITH privileges_data AS (
    {% if target.type == 'postgres' -%}
        SELECT schema_name
            , 'OWNERSHIP' AS privilege_name
            , schema_owner AS grantee_name
        FROM information_schema.schemata
        WHERE schema_name in ('schema_one', 'schema_two')
        UNION
        SELECT n.nspname AS schema_name
            , p.perm AS privilege_name
            , r.rolname AS grantee_name
        FROM pg_catalog.pg_namespace AS n
            CROSS JOIN pg_catalog.pg_roles AS r
            CROSS JOIN (VALUES ('USAGE'), ('CREATE')) AS p(perm)
        WHERE has_schema_privilege(r.oid, n.oid, p.perm)
                AND n.nspname IN ('schema_one', 'schema_two')

    {%- elif target.type == 'snowflake' %}
        SELECT lower(SPLIT("name", '.')[1]) AS schema_name
                , "privilege" AS privilege_name
                ,"grantee_name" AS grantee_name
        FROM (SELECT * FROM TABLE(RESULT_SCAN($scan_query_id_schema_one)))
        UNION
        SELECT lower(SPLIT("name", '.')[1]) AS schema_name
                , "privilege" AS privilege_name
                ,"grantee_name" AS grantee_name
        FROM (SELECT * FROM TABLE(RESULT_SCAN($scan_query_id_schema_two)))
    {%- endif %}
)

, schema_one_data AS (
    SELECT *
    FROM privileges_data
    WHERE schema_name = 'schema_one'
) 

, schema_two_data AS (
    SELECT *
    FROM privileges_data
    WHERE schema_name = 'schema_two'
) 

, deltas AS (
    SELECT a.privilege_name
        , CASE WHEN a.grantee_name = b.grantee_name THEN 0 ELSE 1 END AS delta
    FROM schema_one_data AS a
    LEFT JOIN schema_two_data AS b
    ON a.privilege_name = b.privilege_name
    AND a.grantee_name = b.grantee_name
    UNION
    SELECT a.privilege_name
        , CASE WHEN a.grantee_name = b.grantee_name THEN 0 ELSE 1 END AS delta
    FROM schema_two_data AS a
    LEFT JOIN schema_one_data AS b
    ON a.privilege_name = b.privilege_name
    AND a.grantee_name = b.grantee_name
)

, deltas_grp AS (
    SELECT privilege_name
        , SUM(delta) AS delta
    FROM deltas
    GROUP BY 1
)

SELECT *
FROM deltas_grp