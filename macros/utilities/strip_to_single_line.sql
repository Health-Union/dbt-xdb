{%- macro strip_to_single_line(str) -%}
    {# this removes all side-effect formatting from nested macros, producing a single line sql statement
        SUPPORTS:
            - All
    #}
    {{ str | replace('/*',' ') | replace('*/',' ') | replace('\n',' ') }}
{%- endmacro -%}
