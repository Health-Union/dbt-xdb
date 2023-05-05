{%- macro current_timestamp(timezone = None) -%}
    {#/* Current timestamp function with time zone.
      ARGS:
        - Optional timezone(varchar): timezone that should be applied for timestamp
      RETURNS: Current system timestamp with default timezone or provided one
      SUPPORTS:
        - Postgres
        - Snowflake
    */#}
{%- if timezone is none -%}
    CURRENT_TIMESTAMP
{%- else -%}
    {%- if target.type == 'postgres' -%}
        CURRENT_TIMESTAMP at time zone ('{{ timezone }}')
    {%- elif target.type == 'snowflake' -%}
        CONVERT_TIMEZONE('{{ timezone }}', CURRENT_TIMESTAMP)
    {%- endif -%}
{%- endif -%}
{%- endmacro -%}
