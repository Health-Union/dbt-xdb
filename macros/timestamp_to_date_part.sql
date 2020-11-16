{% macro timestamp_to_date_part(timestamp_t, date_part) %}
  {%- if target.type == 'postgres' -%}
    EXTRACT({{ date_part }} from {{ timestamp_t }})
  {%- elif target.type == 'snowflake' -%}
    TO_DOUBLE(EXTRACT({{ date_part }} from {{ timestamp_t }}))
  {%- else -%}
    {{ xdb.not_supported_exception('timestamp_to_date_part') }}
  {%- endif -%}
{% endmacro %}