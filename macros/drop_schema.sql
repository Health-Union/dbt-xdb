{% macro drop_schema(schema_name) %}

    {#/* Drops schema named as `schema_name` and all its objects.
       ARGS:
         - schema_name (string) : name of schema that will be dropped.
       RETURNS: nothing to the call point.
       SUPPORTS:
            - Postgres
            - Snowflake
    */#}

  {% set sql %}
      DROP SCHEMA IF EXISTS {{schema_name}} CASCADE;
  {% endset %}

  {% do run_query(sql) %}

  {{ log("Schema " ~ schema_name ~ " was dropped successfully.", info=True) }}

{% endmacro %}