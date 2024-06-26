{%- macro clone_schema(schema_one, schema_two, comment_tag='') -%}

    {#/* If `comment_tag` isn't specified, it copies all TABLES, VIEWS, SEQUENCES and FUNCTIONS from `schema_one` to `schema_two`.
         If `comment_tag` argument is specified, it copies TABLES, VIEWS, SEQUENCES and FUNCTIONS that have `comment` metadata field equal to the passed value of `comment_tag` argument.
         Note (!) that for Snowflake DB `schema_one` and `schema_two` values must stick the same format - the both should either have or not have a database name.
       ARGS:
         - schema_one (string) : name of first schema, case-insensitive, mandatory. For Snowflake DB it also could include a database name. Examples: Postgres - 'PROD', Snowflake - 'PROD' or 'DATA_WAREHOUSE.PROD'.
         - schema_two (string) : name of second schema, case-insensitive, mandatory. For Snowflake DB it also could include a database name. Examples: Postgres - 'STAGE', Snowflake - 'STAGE' or 'DATA_WAREHOUSE.STAGE'.
         - comment_tag (string) : value of `comment` metadata field that indicates TABLE, VIEW, SEQUENCE or FUNCTION for copying, case-insensitive, optional. If it's not specified, all TABLES, VIEWS, SEQUENCES and FUNCTIONS from `schema_one` will be copied to `schema_two`.
       RETURNS: nothing to the call point.
       SUPPORTS:
            - Postgres
            - Snowflake
    */#}

    {#/*
    Note about `comment_tag` arg:
        Postgres DB doesn't support tags mechanism as Snowflake does so to make this macro more general metadata field `comment` is supposed to be used to filter objects needed to have in target schema.
        All of such objects have to be marked by a special comment.
    Example:
        dbt run-operation clone_schema --args '{schema_one: prod, schema_two: stage, comment_tag: incremental}' --target snowflake
    */#}

    {#/*
        This block of code initiates schemas-related variables.
    */#}
    {% set schema_one_short_name = schema_one %}
    {% set schema_one_database = '-1' %}
    {% if schema_one.split('.') | length == 2 -%}
        {% set schema_one_short_name = schema_one.split('.')[1] %}
        {% set schema_one_database = schema_one.split('.')[0] %}
    {%- endif %}

    {% set schema_two_short_name = schema_two %}
    {% set schema_two_database = '-1' %}
    {% if schema_two.split('.') | length == 2 -%}
        {% set schema_two_short_name = schema_two.split('.')[1] %}
        {% set schema_two_database = schema_two.split('.')[0] %}
    {%- endif %}


    {%- if target.type == 'postgres' -%}

        {#/*
            This block of code is intended to catch invalid values for the schemas' names.
        */#}
        {% if schema_one_database != '-1' or schema_two_database != '-1' -%}
            {{ exceptions.raise_compiler_error('The `schema_one` and `schema_two` must not include a database name for the Postgres DB adapter.') }}
        {%- elif schema_one == schema_two -%}
            {{ exceptions.raise_compiler_error('The `schema_one` and `schema_two` must be a different schemas!') }}
        {%- endif %}

        {% set set_pg_function %}

        {#/*
            There are neither special clone schema command or procedure in Postgres shipped.
            The subsequent pgSQL part of macro is predominantly based on this opensource script (https://www.postgresql.org/message-id/CANu8FiyJtt-0q%3DbkUxyra66tHi6FFzgU8TqVR2aahseCBDDntA%40mail.gmail.com) from Internet.
            Code style of it is bit sophisticated and might not so clear, because of lots of original artefacts and mechanisms left here. Rewriting it now was considered to be a bit redundant, but can be done some time later.
        */#}
        
            CREATE OR REPLACE FUNCTION pg_clone_schema(source_schema text, 
                                                       dest_schema text, 
                                                       comment_tag text='', 
                                                       include_recs boolean=true)
            RETURNS void AS

            $BODY$
            DECLARE
                tbl_oid             oid;
                func_oid            oid;
                object             text;
                description_value  text;
                buffer             text;
                srctbl             text;
                default_           text;
                column_            text;
                qry                text;
                dest_qry           text;
                v_def              text;
                count_rows       bigint;
                seqval           bigint;
                sq_last_value    bigint;
                sq_max_value     bigint;
                sq_start_value   bigint;
                sq_increment_by  bigint;
                sq_min_value     bigint;
                sq_cache_value   bigint;
                sq_log_cnt       bigint;
                sq_is_called    boolean;
                sq_is_cycled    boolean;
                sq_cycled      char(10);

            BEGIN
            
            --1. Create schema.
            EXECUTE 'DROP SCHEMA IF EXISTS ' || quote_ident(dest_schema) || ' CASCADE; CREATE SCHEMA ' || quote_ident(dest_schema);

            --2. Create sequences.
            --2.1. Fetching of count of sequences.
            SELECT count(*) INTO count_rows 
            FROM information_schema.sequences as t
            LEFT JOIN pg_catalog.pg_description AS pgc
            ON CONCAT_WS('.', t.sequence_schema, t.sequence_name)::regclass::oid = pgc.objoid
            WHERE t.sequence_schema = quote_ident(source_schema)
                AND case when comment_tag = '' then '' else description end = comment_tag;

            --2.2. Checking of count of sequences.
            IF count_rows > 0 THEN
                FOR object in
                    SELECT sequence_name::text
                    FROM information_schema.sequences as t
                    LEFT JOIN pg_catalog.pg_description AS pgc
                    ON CONCAT_WS('.', sequence_schema, sequence_name)::regclass::oid = pgc.objoid
                    WHERE t.sequence_schema = quote_ident(source_schema)
                        AND case when comment_tag = '' then '' else pgc.description end = comment_tag

                --2.3. Generating of sequence-related SQL statements.
                LOOP
                    EXECUTE 'CREATE SEQUENCE ' || quote_ident(dest_schema) || '.' || quote_ident(object);
                    srctbl := quote_ident(source_schema) || '.' || quote_ident(object);

                    EXECUTE 'SELECT b.last_value, a.seqmax, a.seqstart, a.seqincrement, a.seqmin, a.seqcache, b.log_cnt, a.seqcycle, b.is_called FROM pg_catalog.pg_sequence as a INNER JOIN (SELECT ''' || quote_ident(source_schema) || '.' || quote_ident(object) || '''::regclass::oid as seqrelid, * from ' || quote_ident(source_schema) || '.' || quote_ident(object) ||  ') as b on a.seqrelid = b.seqrelid;' 
                    INTO sq_last_value, sq_max_value, sq_start_value, sq_increment_by, sq_min_value, sq_cache_value, sq_log_cnt, sq_is_cycled, sq_is_called ;

                    IF sq_is_cycled THEN sq_cycled := 'CYCLE'; ELSE sq_cycled := 'NO CYCLE'; END IF;

                    EXECUTE 'ALTER SEQUENCE '   || quote_ident(dest_schema) || '.' || quote_ident(object) 
                            || ' INCREMENT BY ' || sq_increment_by
                            || ' MINVALUE '     || sq_min_value 
                            || ' MAXVALUE '     || sq_max_value
                            || ' START WITH '   || sq_start_value
                            || ' RESTART '      || sq_min_value 
                            || ' CACHE '        || sq_cache_value 
                            || sq_cycled || ' ;' ;

                    buffer := quote_ident(dest_schema) || '.' || quote_ident(object);
                    IF include_recs THEN
                            EXECUTE 'SELECT setval( ''' || buffer || ''', ' || sq_last_value || ', ' || sq_is_called || ');' ; 
                    ELSE
                            EXECUTE 'SELECT setval( ''' || buffer || ''', ' || sq_start_value || ', ' || sq_is_called || ');' ;
                    END IF;

                    EXECUTE 'SELECT description FROM pg_catalog.pg_description WHERE objoid = ''' || quote_ident(source_schema) || '.' || quote_ident(object) || '''::regclass::oid' INTO description_value; 
                    IF description_value IS NOT NULL THEN
                            EXECUTE 'COMMENT ON SEQUENCE ' || quote_ident(dest_schema) || '.' || quote_ident(object)  || ' IS ''' || description_value ||''';'; 
                    END IF;

                END LOOP;
            END IF;

            --3. Create tables.
            --3.1. Fetching of count of tables.
            SELECT count(*) INTO count_rows 
            FROM information_schema.tables as t
            LEFT JOIN pg_catalog.pg_description AS pgc
            ON CONCAT_WS('.', table_schema, table_name)::regclass::oid = pgc.objoid
            WHERE table_schema = quote_ident(source_schema)
                AND table_type = 'BASE TABLE'
                AND case when comment_tag = '' then '' else description end = comment_tag;

            --3.2. Checking of count of tables.
            IF count_rows > 0 THEN
                FOR object IN
                    SELECT TABLE_NAME::text 
                    FROM information_schema.tables as t
                    LEFT JOIN pg_catalog.pg_description AS pgc
                    ON CONCAT_WS('.', table_schema, table_name)::regclass::oid = pgc.objoid
                    WHERE table_schema = quote_ident(source_schema)
                        AND table_type = 'BASE TABLE'
                        AND case when comment_tag = '' then '' else description end = comment_tag

                --3.3. Generating of tables-related SQL statements.
                LOOP
                    buffer := dest_schema || '.' || quote_ident(object);
                    EXECUTE 'CREATE TABLE ' || buffer || ' (LIKE ' || quote_ident(source_schema) || '.' || quote_ident(object) 
                        || ' INCLUDING ALL)';

                    IF include_recs THEN
                        EXECUTE 'INSERT INTO ' || buffer || ' SELECT * FROM ' || quote_ident(source_schema) || '.' || quote_ident(object) || ';';
                    END IF;

                    FOR column_, default_ IN
                        SELECT column_name::text, 
                                REPLACE(column_default::text, source_schema, dest_schema) 
                            FROM information_schema.COLUMNS 
                        WHERE table_schema = dest_schema 
                            AND TABLE_NAME = object 
                            AND column_default LIKE 'nextval(%' || quote_ident(source_schema) || '%::regclass)'
                    LOOP
                        EXECUTE 'ALTER TABLE ' || buffer || ' ALTER COLUMN ' || column_ || ' SET DEFAULT ' || default_;
                    END LOOP;

                    EXECUTE 'SELECT description FROM pg_catalog.pg_description WHERE objoid = ''' || quote_ident(source_schema) || '.' || quote_ident(object) || '''::regclass::oid' INTO description_value; 
                    IF description_value IS NOT NULL THEN
                            EXECUTE 'COMMENT ON TABLE ' || quote_ident(dest_schema) || '.' || quote_ident(object)  || ' IS ''' || description_value ||''';'; 
                    END IF;
                END LOOP;
            END IF;

            --4. Add foreign key constraints.
            --4.1. Generating of constraints-related SQL statements.
            FOR qry IN
                SELECT 'ALTER TABLE ' || quote_ident(dest_schema) || '.' || quote_ident(rn.relname) 
                                    || ' ADD CONSTRAINT ' || quote_ident(ct.conname) || ' ' || pg_get_constraintdef(ct.oid) || ';'
                FROM pg_constraint ct
                INNER JOIN pg_class rn 
                ON rn.oid = ct.conrelid
                WHERE connamespace = source_schema::regnamespace
                    AND rn.relkind = 'r'
                    AND ct.contype = 'f'
                LOOP
                EXECUTE qry;
                END LOOP;

            --5. Create views.
            IF comment_tag = '' THEN

                --5.1. Fetching of count of views.
                SELECT count(*) INTO count_rows 
                FROM information_schema.views
                WHERE table_schema = quote_ident(source_schema);

                --5.2. Checking of count of views.
                IF count_rows > 0 THEN
                    FOR object IN
                        SELECT table_name::text,
                            view_definition 
                        FROM information_schema.views
                        WHERE table_schema = quote_ident(source_schema)

                    --4.3. Generating of views-related SQL statements.
                    LOOP
                        buffer := dest_schema || '.' || quote_ident(object);
                        SELECT view_definition INTO v_def
                        FROM information_schema.views
                        WHERE table_schema = quote_ident(source_schema)
                            AND table_name = quote_ident(object);
                        EXECUTE 'CREATE OR REPLACE VIEW ' || buffer || ' AS ' || v_def || ';' ;
                    END LOOP;

                    EXECUTE 'SELECT description FROM pg_catalog.pg_description WHERE objoid = ''' || quote_ident(source_schema) || '.' || quote_ident(object) || '''::regclass::oid' INTO description_value; 
                    IF description_value IS NOT NULL THEN
                            EXECUTE 'COMMENT ON VIEW ' || quote_ident(dest_schema) || '.' || quote_ident(object)  || ' IS ''' || description_value ||''';'; 
                    END IF;
                END IF;
            END IF;

            --6. Create functions.
                FOR func_oid IN
                    SELECT oid
                    FROM pg_proc 
                    WHERE pronamespace = source_schema::regnamespace

                --6.1. Generating of functions-related SQL statements.
                LOOP      
                    SELECT pg_get_functiondef(func_oid) INTO qry;
                    SELECT replace(qry, source_schema, dest_schema) INTO dest_qry;
                    EXECUTE dest_qry;
                END LOOP;

            RETURN; 
            END;
            $BODY$
            LANGUAGE plpgsql VOLATILE
            COST 100;

        {% endset %} 

        {% do run_query(set_pg_function) %}

        {#/*
            The subsequent block is setting of SQL-statements block by calling to `set_pg_function` function declared before.
        */#}
        {% set sql %}
            SELECT pg_clone_schema('{{schema_one}}', '{{schema_two}}', '{{comment_tag}}', true);
        {% endset %}

    {%- elif target.type == 'snowflake' -%}
        {#/*
            We don't use CLONE SCHEMA option here, because this function doesn’t copy all grants for objects when used at the schema level.
            Related extra information see here - https://docs.snowflake.com/en/user-guide/object-clone
            Because of this effect we are applying a COPY GRANTS syntax to single objects grant statements which are generated in loop.
        */#}

        {#/*
            This block of code is intended to catch invalid values for the schemas' names.
        */#}
        {% if (schema_one_database == '-1' and schema_two_database != '-1') 
            or (schema_one_database != '-1' and schema_two_database == '-1') -%}
            {{ exceptions.raise_compiler_error('The both of the `schema_one` and `schema_two` schemas must either have or not have a database name.') }}
        {%- elif (schema_one_short_name == schema_two_short_name) and (schema_one_database == schema_two_database) -%}
            {{ exceptions.raise_compiler_error('The `schema_one` and `schema_two` must be a different schemas!') }}
        {%- endif %}

        {#/*
            The subsequent block fetches signatures of and comments on all functions in `schema_one`.
        */#}

        {% set fetch_functions_names %}
            SELECT
                function_name||regexp_replace(argument_signature,'\\w+\\s(\\w+)','\\1') AS full_function_name
                , coalesce(comment, '-1') AS comment
            FROM information_schema.functions
            WHERE LOWER(function_schema) = LOWER('{{schema_one_short_name}}')
        {% if comment_tag != '' -%}
                    AND LOWER(comment) = LOWER('{{comment_tag}}')
            {%- endif %}
        {% endset %}

        {% set functions_names = run_query(fetch_functions_names) %}

        {% set fetch_tagged_objects %}
                USE SCHEMA {{schema_one}};
                SELECT * FROM (
                    SELECT
                        CASE WHEN is_transient = 'YES' THEN 'TRANSIENT TABLE' ELSE 'TABLE' END AS type
                        , table_name AS name
                        , NULL AS object_definition
                        , coalesce(comment, '-1') AS comment
                        , 0 AS order_rank
                    FROM information_schema.tables
                    WHERE LOWER(table_schema) = LOWER('{{schema_one_short_name}}')
        {% if comment_tag != '' -%}
                        AND LOWER(comment) = LOWER('{{comment_tag}}')
        {%- endif %}
                        AND table_type = 'BASE TABLE'
                    UNION ALL
                    SELECT * FROM (
                        WITH views_data AS (
                            SELECT
                                'VIEW' AS type
                                , table_name AS name
                                , view_definition AS object_definition
                                , coalesce(comment, '-1') AS comment
                            FROM information_schema.views
                            WHERE LOWER(table_schema) = LOWER('{{schema_one_short_name}}')
        {% if comment_tag != '' -%}
                                AND LOWER(comment) = LOWER('{{comment_tag}}')
        {%- endif %}
                        )
                        , names AS (
                            SELECT NAME AS view_name FROM views_data
                            )
                        SELECT
                            views_data.TYPE
                            , views_data.NAME
                            , views_data.object_definition
                            , views_data.comment
                            , SUM(CASE 
                                    WHEN CONTAINS(lower(object_definition), lower(view_name))
                                        AND VIEW_NAME <> NAME THEN 1
                                    ELSE 0
                                END) AS order_rank
                        FROM views_data, names
                        GROUP BY 1, 2, 3, 4
                    ) views
                    UNION ALL
                    SELECT
                        'SEQUENCE' AS type
                        , sequence_name AS name
                        , NULL AS object_definition
                        , coalesce(comment, '-1') AS comment
                        , 0 AS order_rank
                    FROM information_schema.sequences
                    WHERE LOWER(sequence_schema) = LOWER('{{schema_one_short_name}}')
        {% if comment_tag != '' -%}
                        AND LOWER(comment) = LOWER('{{comment_tag}}')
        {%- endif %}
                    {%- if functions_names is defined -%}
                        {% for i in functions_names -%}
                    UNION ALL
                    SELECT                                                                                                                                                                                                                                                                                                                                                                             
                        'FUNCTION' AS type
                        , '{{i[0]}}' AS name
                        , get_ddl('function', '{{i[0]}}') AS object_definition
                        , '{{i[1]}}' AS comment
                        , 0 AS order_rank
                            {% endfor %}
                    {%- endif -%}
                ) ORDER BY order_rank ASC;
        {% endset %}

        {% set tagged_objects = run_query(fetch_tagged_objects) %}

        {% set sql %}
                CREATE OR REPLACE SCHEMA {{schema_two}};
            {% for i in tagged_objects %}
                {%- if i[0] == 'SEQUENCE' -%}
                    {{"CREATE " ~ i[0] ~ " " ~ schema_two ~ "." ~ i[1] ~ " CLONE " ~ schema_one ~ "." ~ i[1] ~ ";"}}
                {%- else -%}
                    {%- if i[0] == 'TABLE' or i[0] == 'TRANSIENT TABLE' -%}
                    {{"CREATE " ~ i[0] ~ " " ~ schema_two ~ "." ~ i[1] ~ " CLONE " ~ schema_one ~ "." ~ i[1] ~ " COPY GRANTS;"}}
                    {%- else -%}
                    {#/*
                        This block provides DDLs for creation of functions and views.
                    */#}
                        {% set view_query = i[2].replace(schema_one ~ '.', schema_two ~ '.') %}
                        {{ view_query }}
                        {%- if i[3] != '-1' -%}
                    {{"COMMENT ON " ~ i[0] ~ " " ~ schema_two ~ "." ~ i[1] ~ " IS '" ~ i[3] ~ "';"}}
                        {%- endif -%}
                    {%- endif -%}
                {%- endif -%}
            {% endfor %}
        {% endset %}

    {%- else -%}
        {{ xdb.not_supported_exception('The clone_schema() macro doesn`t support this type of database target.') }}
    {%- endif -%}

    {#/*
        The subsequent block triggers running of SQL-statements prepared in `sql` variable.
    */#}
    {% do run_query(sql) %}

    {%- if comment_tag == '' -%}
        {{ log("All objectes were successfully copied from schema '" ~ schema_one ~ "' to schema '" ~ schema_two ~  "'." , info=True) }}
    {%- else -%}
        {{ log("All objectes commented as '" ~ comment_tag ~ "' were successfully copied from schema '" ~ schema_one ~ "' to schema '" ~ schema_two ~  "'." , info=True) }}
    {%- endif -%}

{%- endmacro -%}