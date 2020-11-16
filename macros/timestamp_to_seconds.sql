{% macro timestamp_to_seconds(timestamp_t) %}
  {%- if target.type == 'postgres' -%}
    EXTRACT(epoch from {{ timestamp_t }})
  {%- elif target.type == 'snowflake' -%}
    TO_DOUBLE(EXTRACT(epoch from {{ timestamp_t }}))
  {%- else -%}
        {{ xdb.not_supported_exception('timestamp_to_seconds') }}
  {%- endif -%}
{% endmacro %}
