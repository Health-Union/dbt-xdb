{% macro json_extract_path_text(column, path_vals) %}
  {#
    Extracts the value at `path_vals` from the json typed `column` (or expression)
       ARGS:
         - `column` (string) the column name (or expression) to extract the values from
         - `path_vals` (list[string/int]) the path to the desired value. 
           Strings values are assumed to be keys
           Integer values are assumed to index arrays
           Integers that are typed as strings are assumed to be keys

           Note that in some DB cases it does not matter the typing:
            - postgres: '0' will indicate the key "0" or first array item based on context

       RETURNS: (varchar) The value at the given path in the column value
  #}
  {% if target.type == 'postgres' %}
    {% set expr = namespace(value="json_extract_path_text(" ~ column ~ ", ") %}
    {% for val in path_vals %}
      {% set expr.value = expr.value ~ "'" ~ val ~ "'" %}
      {% if not loop.last %}
        {% set expr.value = expr.value ~ ", " %}
      {% endif %}
    {% endfor %}
    {% set expr.value = expr.value ~ ")" %}
  {% elif target.type == 'snowflake' %}
    {% set expr = namespace(value="json_extract_path_text(" ~ column ~ ", '") %}
    {% for val in path_vals %}
      {% if val is integer %}
        {% set append_val = val %}
        {% set expr.value = expr.value ~ '[' ~ append_val ~ ']' %}
      {% else %}
        {% if not loop.first %}
          {# no . for first item #}
          {% set expr.value = expr.value ~ '."' ~ val ~ '"' %}
        {% else %}
          {% set expr.value = expr.value ~ '"' ~ val ~ '"' %}
        {% endif %}
      {% endif %}
    {% endfor %}
    {% set expr.value = expr.value ~ "')" %}
  {% else %}
    {{raise_not_supported_error()}}
  {% endif %}
  {{ return(expr.value) }}
{% endmacro %}