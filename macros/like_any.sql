{%- macro like_any(patterns, escape = '\\\\') -%}
    {#/* Regular like any function that works similar to like but with few possible patterns.
      ARGS:
        - patterns (tuple of strings): patterns for like statement
        - escape (string): chars that will be used as an escape symbol for snowflake only!!
      RETURNS: Varchars that are matсhing provided patterns.
      SUPPORTS:
            - Postgres
            - Snowflake
    */#}
{%- if target.type == 'postgres' -%}
    {%- set postgres_patterns = patterns|list -%}
    LIKE ANY(ARRAY{{ postgres_patterns }})
{%- elif target.type == 'snowflake' -%}
    LIKE ANY{{ patterns }} ESCAPE '{{ escape }}'
{%- else -%}
    {{ not_supported_exception('macro_name') }}
{%- endif  -%}
{%- endmacro -%}
