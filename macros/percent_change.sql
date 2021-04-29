{%- macro percent_change(x_0, x_N) -%}
    {# Computes the percent change between `x_0` and `x_N` (numeric)
       ARGS:
         - x_0 (numeric) is the initial value
         - x_N (numeric) is the final value
       RETURNS: the percent change between `x_0` and `x_N` (numeric)
       SUPPORTS:
            - All (purely arithmetic)
    #}

    {{ xdb.relative_change(x_0, x_N) }} * 100.0

{%- endmacro -%}