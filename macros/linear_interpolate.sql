{%- macro linear_interpolate(x_i, x_0, y_0, x_1, y_1) -%}
  {#/* Calculates linearly interpolated value given two data points
      ARGS:
        - x_i (numeric): the x value to calculate the interpolated value for 
        - x_0 (numeric): x value of first data point
        - y_0 (numeric): y value of first data point
        - x_1 (numeric): x value of second data point
        - y_1 (numeric): y value of second data point
      RETURNS: linearly interpolated value (numeric)
      SUPPORTS:
            - All (purely arithmetic)
  */#}
(({{y_1}} - {{y_0}}) / ({{x_1}} - {{x_0}})) * ({{x_i}} - {{x_0}}) + {{y_0}}
{%- endmacro -%}