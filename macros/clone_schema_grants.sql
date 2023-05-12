{% macro clone_schema_grants(schema_one, schema_two) %}

    {#/* Replaces existing grants on schema `schema_two` by ones on schema `schema_one`.
        NOTE:
            This macro is supposed to be called by user that has ownership grants on both schemas passed (for example via belonging to the roles own them in Snowflake). Otherwise an aсsess error will be raised.
       ARGS:
         - schema_one (string) : name of first schema. 
            pattern <database_name.schema_name> is available only for Snowflake DB target
            pattern <schema_name> is available for both Postgres and Snowflake DB targets (in this case <database_name> value will be taken from session settings).
         - schema_two (string) : name of second schema.
            pattern <database_name.schema_name> is available only for Snowflake DB target
            pattern <schema_name> is available for both Postgres and Snowflake DB targets (in this case <database_name> value will be taken from session settings).
       RETURNS: nothing to the call point.
       SUPPORTS:
         - Postgres
         - Snowflake
    */#}

    {%- if target.type == 'postgres' -%}

        {#/*1. Fetching grants details.*/#}
        {% set get_target_grants %}
            SELECT 
                p.perm AS privilege
                , r.rolname AS role_name
            FROM pg_catalog.pg_namespace AS n
                CROSS JOIN pg_catalog.pg_roles AS r
                CROSS JOIN (VALUES ('USAGE'), ('CREATE')) AS p(perm)
            WHERE has_schema_privilege(r.oid, n.oid, p.perm)
                    and n.nspname = '{{schema_one}}'
        {% endset %}
        {% set target_grants = run_query(get_target_grants) %}
        
        {#/*2. Fetching the name of owner.*/#}
        {% set get_target_owner %}
            SELECT schema_owner
            FROM information_schema.schemata
            WHERE schema_name = '{{schema_one}}'
        {% endset %}
        {% if execute %}
        {% set target_owner = run_query(get_target_owner)[0][0] %}
        {% else %}
        {% set target_owner = '' %}
        {% endif %}

        {#/*3. Fetching revoke grants details.*/#}
        {% set get_revoke_grants %}
            SELECT 
                p.perm AS privilege
                , r.rolname AS role_name
            FROM pg_catalog.pg_namespace AS n
                CROSS JOIN pg_catalog.pg_roles AS r
                CROSS JOIN (VALUES ('USAGE'), ('CREATE')) AS p(perm)
            WHERE has_schema_privilege(r.oid, n.oid, p.perm)
                    and n.nspname = '{{schema_two}}'
        {% endset %}
        {% set revoke_grants = run_query(get_revoke_grants) %}

        {#/*3. Cloning ownership, revoke current grants and applying target ones that are on `schema_one` to `schema_two`.*/#}
        {% set sql %}
                {{"ALTER SCHEMA " ~ schema_two ~ " OWNER TO " ~ target_owner ~ ";"}}
            {% for i in target_grants %}
                {{"GRANT " ~ i[0] ~ " ON SCHEMA " ~ schema_two ~ " TO " ~ i[1] ~ ";"}}
            {% endfor %}
            {% for i in revoke_grants %}
                {{"REVOKE " ~ i[0] ~ " ON SCHEMA " ~ schema_two ~ " FROM " ~ i[1] ~ ";"}}
            {% endfor %}
        {% endset %}

    {%- elif target.type == 'snowflake' -%}

        {#/*1. Scanning for grants on `schema_one`.*/#}
        {% set scan_grants %}
            SHOW GRANTS ON SCHEMA {{schema_one}};
        {% endset %}
        {% do run_query(scan_grants) %}

        {#/*2. Fetching scan query ID.*/#}
        {% if '.' in schema_one %}
        {% set database_one = schema_one.split('.')[0] %}
        {% else %}
            {% if execute %}
                {% set get_database %}
                    SELECT CURRENT_DATABASE();
                {% endset %}
                {% set database_one = run_query(get_database)[0][0] %}
                {% else %}
                {% set database_one = '' %}
                {% endif %}
        {% endif %}
        {% set get_scan_query_id %}
            SELECT query_id
            FROM TABLE({{database_one}}.INFORMATION_SCHEMA.QUERY_HISTORY())
            WHERE query_text = 'SHOW GRANTS ON SCHEMA {{schema_one}};'
            ORDER BY start_time DESC LIMIT 1
        {% endset %}
        {% if execute %}
        {% set scan_query_id = run_query(get_scan_query_id)[0][0] %}
        {% else %}
        {% set scan_query_id = '' %}
        {% endif %}

        {#/*3. Fetching grants details.*/#}
        {% set get_target_grants %}
            SELECT "privilege"
                ,"granted_on"
                ,"granted_to"
                ,"grantee_name"
                , CASE WHEN "privilege" = 'OWNERSHIP' THEN 1 ELSE 2 END AS order_flag
            FROM (SELECT * FROM TABLE(RESULT_SCAN('{{scan_query_id}}')))
            WHERE "privilege" NOT IN ('CREATE ANOMALY_DETECTION', 'CREATE STATEFUL_FORECAST', 'CREATE BUDGET')
            --This condition is a work around to avoid an error by this link -  https://cloud.getdbt.com/deploy/159/projects/3671/runs/149552418
            --which is related to invention of 3 new privileges: 'CREATE ANOMALY_DETECTION', 'CREATE STATEFUL_FORECAST', 'CREATE BUDGET' which
            --can't be either granted or revoked by a special separate command, but can be provided by ALL-syntax.
            --It might be removed after having grant and revoke options for them in some future.
            ORDER BY 5
        {% endset %}
        {% set target_grants = run_query(get_target_grants) %}

        {#/*4. Cloning ownership and applying grants that are on `schema_one` to `schema_two`.*/#}
        {% set sql %}
            {% for i in target_grants %}
                {%- if i[0] == 'OWNERSHIP' -%}
                    {{"GRANT " ~ i[0] ~ " ON "  ~ i[1] ~ " " ~ schema_two ~ " TO " ~ i[2] ~ " " ~ i[3] ~ " REVOKE CURRENT GRANTS;"}}
                    {{"USE ROLE " ~ i[3] ~ ";"}}
                    {{"GRANT ALL ON "  ~ i[1] ~ " " ~ schema_two ~ " TO " ~ i[2] ~ " " ~ i[3] ~ ";"}}
                    {#/*This GRANT ALL command is a work around to avoid an error by this link -  https://cloud.getdbt.com/deploy/159/projects/3671/runs/149552418.
                        See the previous comment.*/#}
                {%- else -%}
                     {{"GRANT " ~ i[0] ~ " ON "  ~ i[1] ~ " " ~ schema_two ~ " TO " ~ i[2] ~ " " ~ i[3] ~ ";"}}
                {%- endif -%}
            {% endfor %}
        {% endset %}

    {%- else -%}
        {{ xdb.not_supported_exception('The clone_schema_grants() macro doesn`t support this type of database target.') }}
    {%- endif -%}

    {% do run_query(sql) %}
    {{ log("Grants that are on `schema_one` have been applied on `schema_two` successfully.", info=True) }}

{% endmacro %}

 by ones on schema `schema_one`