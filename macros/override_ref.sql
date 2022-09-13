{% macro override_ref(model_name) %}
   {#/* The macro which behaves as builtin macro `ref()`, but omits database and schema rendering in references of views (this behaviour for Snowflake target only).
       ARGS:
         - model_name (string) : name of model.
       RETURNS: reference on corresponding object in target database.
       SUPPORTS:
            - Postgres
            - Snowflake
    */#}

  {%- if model.config.materialized == 'view' and target.type == 'snowflake' -%}
    {% do return(builtins.ref(model_name).include(database=false, schema=false)) %}

  {%- else -%}
    {% do return(builtins.ref(model_name)) %}

  {%- endif -%}

{% endmacro %}