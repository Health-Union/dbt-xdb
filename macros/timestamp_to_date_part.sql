{% macro timestamp_to_date_part(timestamp_t, date_part) %}
  {#/* Ensures that result of EXTRACT in Snowflake is a double to match the default behavior of EXTRACT in postgres
      ARGS:
        - timestamp_t (timestamp): timestamp to extract the date_part from 
        - date_part (string): tested for 'epoch', 'year', 'month', 'day', 'hour', 'minute', 'second'
      RETURNS: double 
      SUPPORTS:
            - Postgres
            - Snowflake
  */#}
{%- if target.type == 'postgres' -%}
    EXTRACT({{ date_part }} FROM {{ timestamp_t }})
{%- elif target.type == 'snowflake' -%}
    TO_DOUBLE(EXTRACT({{ date_part }} from {{ timestamp_t }}))
{%- else -%}
    {{ xdb.not_supported_exception('timestamp_to_date_part') }}
{%- endif -%}
{% endmacro %}