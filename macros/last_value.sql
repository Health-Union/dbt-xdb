{% macro last_value(col, data_type, partition_by, order_by) %}
  {%- if target.type == 'postgres' -%}
    last_value({{ col }}::{{ data_type }}) 
    OVER (
      PARTITION BY {{ partition_by }} 
      ORDER BY {{ order_by }}
      RANGE BETWEEN 
        UNBOUNDED PRECEDING AND 
        UNBOUNDED FOLLOWING
    )
  {%- elif target.type == 'snowflake' -%}
    last_value({{ col }}::{{ data_type }}) 
    OVER (
      PARTITION BY {{ partition_by }}
      ORDER BY {{ order_by }}
    )
  {%- else -%}
    {{ xdb.not_supported_exception('last_value') }}
  {%- endif -%}
{% endmacro %}