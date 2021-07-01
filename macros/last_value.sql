{%- macro last_value(col, data_type, partition_by, order_by) -%}
  {#/* Window function that returns the last value within an ordered group of values.
      ARGS:
        - col (string): the column to get the value from 
        - data_type (string): the data type to cast col to
        - partition_by (string): the expression to be partitioned by, e.g. "id, type"
        - order_by (string): the expression to order the partitioned data by, e.g. "date DESC"
      RETURNS: The last value within an ordered group of values.
      SUPPORTS:
            - Postgres
            - Snowflake
  */#}
{%- if target.type == 'postgres' -%}
LAST_VALUE({{ col }}::{{ data_type }})
    OVER (
        PARTITION BY {{ partition_by }}
        ORDER BY {{ order_by }}
        RANGE BETWEEN
        UNBOUNDED PRECEDING AND
        UNBOUNDED FOLLOWING
    )
{%- elif target.type == 'snowflake' -%}
LAST_VALUE({{ col }}::{{ data_type }})
OVER (
    PARTITION BY {{ partition_by }}
    ORDER BY {{ order_by }}
)
{%- else -%}
{{ xdb.not_supported_exception('last_value') }}
{%- endif -%}
{%- endmacro -%}