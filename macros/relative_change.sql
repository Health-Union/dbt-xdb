{%- macro relative_change(x_0, x_N) -%}
    {# Computes the relative change between `x_0` and `x_N` values
       ARGS:
         - x_0 (numeric) is the initial value
         - x_N (numeric) is the final value
       RETURNS: the relative change between `x_0` and `x_N` (numeric)
       SUPPORTS:
            - All (purely arithmetic)
    #}

    (( {{ x_N }} - {{ x_0 }} ) / {{ x_0 }})

{%- endmacro -%}
