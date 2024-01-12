{% macro swap_schema(schema_one, schema_two) %}

    {#/* Swaps the names between two specified schemas.
       ARGS:
         - schema_one (string) : name of first schema.
         - schema_two (string) : name of second schema.
       RETURNS: nothing to the call point.
       SUPPORTS:
            - Postgres
            - Snowflake
    */#}

    {%- if target.type == 'postgres' -%} 
        {% set sql %}
            ALTER SCHEMA {{schema_one}} RENAME TO tmp_schema;
            ALTER SCHEMA {{schema_two}} RENAME TO {{schema_one}};
            ALTER SCHEMA tmp_schema RENAME TO {{schema_two}};
        {% endset %}

    {%- elif target.type == 'snowflake' -%}
        {% set sql %}
            ALTER SCHEMA {{schema_one}} SWAP WITH {{schema_two}};
        {% endset %}

    {%- else -%}
        {{ xdb.not_supported_exception('The swap_schema() macro doesn`t support this type of database target.') }}
    {%- endif -%}

    {% do run_query(sql) %}

    {{ log("Schemas' names were swapped successfully.", info=True) }}

{% endmacro %}