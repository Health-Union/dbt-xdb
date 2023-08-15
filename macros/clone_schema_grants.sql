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
        {% set sql_set_grants %}
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
        {% set query_to_get_source_grants = xdb._get_schema_grants_query(schema_one) %}
        {% set source_grants = run_query(query_to_get_source_grants) %}

        {#/*2. Cloning ownership that are on `schema_one` to `schema_two`.*/#}
        {% set sql_set_ownership %}
            {% for i in source_grants %}
                {%- if i[0] == 'OWNERSHIP' -%}
                {{"GRANT " ~ i[0] ~ " ON "  ~ i[1] ~ " " ~ schema_two ~ " TO " ~ i[2].replace("_", " ") ~ " " ~ i[3] ~ " REVOKE CURRENT GRANTS;"}}
                {{"USE ROLE " ~ i[3] ~ ";"}}
                {{"GRANT ALL ON "  ~ i[1] ~ " " ~ schema_two ~ " TO " ~ i[2].replace("_", " ") ~ " " ~ i[3] ~ ";"}}
                {%- endif -%}
            {% endfor %}
        {% endset %}
        {% do run_query(sql_set_ownership) %}

        {#/*3. Scanning for current grants on `schema_two`.*/#}
        {% set query_to_get_target_grants = xdb._get_schema_grants_query(schema_two) %}
        {% set target_grants = run_query(query_to_get_target_grants) %}

        {#/*4. Applying remaining grants to `schema_two`.*/#}
        {% set sql_set_grants %}
            {% for i in source_grants %}
                {% set already_present_grant_flag = false %}
                {%- if i[0] != 'OWNERSHIP' -%}
                    {% for j in target_grants %}
                        {%- if i[0] == j[0] and i[1] == j[1] and i[2] == j[2] and i[3] == j[3] -%}
                            {% set already_present_grant_flag = true %}
                            {{'--'}}
                        {%- endif -%}
                    {% endfor %}
                    {%- if already_present_grant_flag == false -%}
                    {{"GRANT " ~ i[0] ~ " ON "  ~ i[1] ~ " " ~ schema_two ~ " TO " ~ i[2].replace("_", " ") ~ " " ~ i[3] ~ ";"}}
                    {%- endif -%}
                {%- endif -%}
            {% endfor %}
            {#/*This is a default workable statement to avoid having attempts of running empty list of commands.*/#}
            {{"SELECT 1;"}}
        {% endset %}

    {%- else -%}
        {{ xdb.not_supported_exception('The clone_schema_grants() macro doesn`t support this type of database target.') }}
    {%- endif -%}

    {#/*Fetching of final list of commands from `sql_set_grants` var.*/#}
    {% do run_query(sql_set_grants) %}
    {{ log("Grants that are on `schema_one` have been applied on `schema_two` successfully.", info=True) }}

{% endmacro %}

{% macro _get_schema_grants_query(schema_name) %}
    {#/*
        This is an auxiliary macro for generating query which provides details
        about applied grants on schema `schema_name` after being fetched.
        SUPPORTS:
            - Snowflake
    */#}
    {#/*1. Scanning for grants on `schema_name`.*/#}
    {% set scan_grants %}
        SHOW GRANTS ON SCHEMA {{schema_name}};
    {% endset %}
    {% do run_query(scan_grants) %}

    {#/*2. Fetching scan query ID.*/#}
    {% if '.' in schema_name %}
    {% set database_one = schema_name.split('.')[0] %}
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
        WHERE query_text = 'SHOW GRANTS ON SCHEMA {{schema_name}};'
        ORDER BY start_time DESC LIMIT 1
    {% endset %}
    {% if execute %}
    {% set scan_query_id = run_query(get_scan_query_id)[0][0] %}
    {% else %}
    {% set scan_query_id = '' %}
    {% endif %}

    {#/*3. Building a query to be fetched.*/#}
    {% set query %}
        SELECT "privilege"
            ,"granted_on"
            ,"granted_to"
            ,"grantee_name"
            , CASE WHEN "privilege" = 'OWNERSHIP' THEN 1 ELSE 2 END AS order_flag
        FROM (SELECT * FROM TABLE(RESULT_SCAN('{{scan_query_id}}')))
        ORDER BY 5
    {% endset %}

    {{ return(query) }}

{%- endmacro -%}