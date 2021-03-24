{% macro extract_json_path(column, path_vals) %}
  {#
    Extracts the value at `path_vals` from the json typed `column` (or expression)
       ARGS:
         - `column` (string) the column name (or expression) to extract the values from
         - `path_vals` (list[string/int]) the path to the desired value. 
           Strings values are assumed to be keys
           Integer values are assumed to index arrays
           Integers that are typed as strings are assumed to be keys

       RETURNS: (varchar) The value at the given path in the column value
  #}
  {% if target.type == 'postgres' %}
    {% set expr = namespace(value=column) %}
    {% for val in path_vals %}
      {% if val is integer %}
        {% set append_val = val %}
      {% else %}
        {% set append_val = "'" ~ val ~ "'" %}
      {% endif %}

      {% if loop.last %}
        {% set expr.value = expr.value ~ '->>' ~ append_val %}
      {% else %}
        {% set expr.value = expr.value ~ '->' ~ append_val %}
      {% endif %}
    {% endfor %}
  {% elif target.type == 'snowflake' %}
    {% set expr = namespace(value=column ~ ':') %}
    {% for val in path_vals %}
      {% if val is integer %}
        {% set append_val = val %}
        {% set expr.value = expr.value ~ '[' ~ append_val ~ ']' %}
      {% else %}
        {% set append_val = "'" ~ val ~ "'" %}
        {% set expr.value = expr.value ~ '.' ~ append_val %}
      {% endif %}
    {% endfor %}
    {% set expr.value = expr.value ~ '::text' %}
  {% else %}
    {{raise_not_supported_error()}}
  {% endif %}
  {{ return(expr.value) }}
{% endmacro %}