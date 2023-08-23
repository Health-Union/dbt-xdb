{%- macro clone_schema(schema_one, schema_two, comment_tag='') -%}

    {#/* 
        Postgres implementation:
            - Copies tables, views, sequences and functions from `schema_one` to `schema_two` if `comment_tag` isn't specified.
            - If `comment_tag` argument is specified, it copies only tables and sequences that have `comment` metadata field equal to the passed value of `comment_tag` argument.

        Snowflake implementation:
            - Copies tables and sequences from `schema_one` to `schema_two`.
            - If `comment_tag` argument is specified, it copies only tables and sequences that have `comment` metadata field equal to the passed value of `comment_tag` argument.

       ARGS:
         - schema_one (string) : name of first schema.
         - schema_two (string) : name of second schema.
         - comment_tag (string) : value of `comment` metadata field that indicates either table or sequence for copying. If it's not specified, all objects from `schema_one` will be copied to `schema_two`.
       RETURNS: nothing to the call point.
       SUPPORTS:
            - Postgres
            - Snowflake
    */#}

    {#/*
    Note about `comment_tag` arg:
        Postgres DB doesn't support tags mechanism as Snowflake does so to make this macro more general metadata field `comment` is supposed to be used to filter objects needed to have in target schema. All of such objects have to be marked by a special comment.
    Example:
        dbt run-operation clone_schema --args '{schema_one: prod, schema_two: stage, comment_tag: incremental}' --target ANALYSIS
    */#}

    {%- if target.type == 'postgres' -%}

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
        {%- if comment_tag == '' -%}
            {% set fetch_tagged_objects %}
                SELECT
                    CASE WHEN is_transient = 'YES' THEN 'TRANSIENT TABLE' ELSE 'TABLE' END AS type
                    , table_name AS name
                FROM information_schema.tables
                WHERE LOWER(table_schema) = LOWER('{{schema_one}}')
                    AND table_type = 'BASE TABLE'
                UNION ALL
                SELECT
                    'SEQUENCE' AS type
                    , sequence_name AS name
                FROM information_schema.sequences
                WHERE LOWER(sequence_schema) = LOWER('{{schema_one}}')
            {% endset %}
        {%- else -%}
            {% set fetch_tagged_objects %}
                SELECT
                    CASE WHEN is_transient = 'YES' THEN 'TRANSIENT TABLE' ELSE 'TABLE' END AS type
                    , table_name AS name
                FROM information_schema.tables
                WHERE LOWER(table_schema) = LOWER('{{schema_one}}')
                    AND LOWER(comment) = LOWER('{{comment_tag}}')
                    AND table_type = 'BASE TABLE'
                UNION ALL
                SELECT
                    'SEQUENCE' AS type
                    , sequence_name AS name
                FROM information_schema.sequences
                WHERE LOWER(sequence_schema) = LOWER('{{schema_one}}')
                    AND LOWER(comment) = LOWER('{{comment_tag}}')
            {% endset %}
        {%- endif -%}

        {% set tagged_objects = run_query(fetch_tagged_objects) %}

        {% set sql %}
                CREATE OR REPLACE SCHEMA {{schema_two}};
            {% for i in tagged_objects %}
                {{"CREATE " ~ i[0] ~ " " ~ schema_two ~ "." ~ i[1] ~ " CLONE " ~ schema_one ~ "." ~ i[1] ~ ";"}}
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