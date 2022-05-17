/* xdb: nocoverage */
{% macro env_generate_schema_name(custom_schema_name, branch_name, default_schema) -%}
{#/* Used in conjunction with generate_schema_name, this macro returns a schema name
        based on the cusrrent working environment
       ARGS:
         - custom_schema_name (string) The configured value of schema in the specified node, or none if a value is not supplied
         - branch_name (string) The current branch name
         - default_schema (string) The default schema name e.g. target.schema
       RETURNS: A schema name.
       SUPPORTS:
            - Postgres
            - Snowflake
    */#}  
  {%- if branch_name == '' -%}
    {%- if custom_schema_name is none -%}
      {{ default_schema }}
    {%- else -%}
      {{ custom_schema_name | trim }}
    {%- endif -%}
  {%- else -%}
    {%- if custom_schema_name is none -%}
      {{ xdb._normalize_schema(branch_name) }}_{{ default_schema }}
    {%- else -%}
      {{ xdb._normalize_schema(branch_name) }}_{{ default_schema }}_{{ custom_schema_name | trim }}
    {%- endif -%}
  {%- endif -%}
{%- endmacro %}

{%- macro _normalize_schema(branch_name) -%}
  {{ branch_name | replace('/','') | replace('-','') | replace('_','') | lower}}
{%- endmacro -%}