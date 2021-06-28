{%- macro generate_uuid(type="v4") -%}
  {#/*
    Generates a uuid value of the given type. Only currently supports v4.

    Prerequisite:
      - Postgres requires the "uuid-ossp" extension to be added to the target database

       ARGS:
         - `type` (string) the type of uuid to generate (defaults to `"v4"`)
       RETURNS: (varchar) The generated uuid value as a varchar
       SUPPORTS:
            - Postgres
            - Snowflake
  */#}
{%- if type == "v4" -%}
    {%- if target.type == 'postgres' -%}
      (uuid_generate_v4()::TEXT)
    {%- elif target.type == 'snowflake' -%}
      uuid_string()
    {%- else -%}
      {{ xdb.not_supported_exception('generate_uuid("v4")') }}
    {%- endif -%}
{%- else -%}
    {{ xdb.not_supported_exception('generate_uuid(' ~ type ~ ')')}}
{%- endif -%}
{%- endmacro -%}