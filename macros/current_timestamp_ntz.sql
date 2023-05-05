{%- macro current_timestamp_ntz() -%}
    {#/* Current timestamp function without timezone info, UTC.
      RETURNS: Current system timestamp without timezone, UTC.
      SUPPORTS:
        - Postgres
        - Snowflake
    */#}
{%- if target.type == 'postgres' -%}
    NOW() at time zone ('UTC')
{%- elif target.type == 'snowflake' -%}
    SYSDATE()
{%- else -%}
    {{ not_supported_exception('current_timestamp_ntz') }}
{%- endif -%}
{%- endmacro -%}
