{% macro linear_interpolate(x_i, x_0, y_0, x_1, y_1) %}
  (({{y_1}} - {{y_0}}) / ({{x_1}} - {{x_0}})) * ({{x_i}} - {{x_0}}) + {{y_0}}
{% endmacro %}