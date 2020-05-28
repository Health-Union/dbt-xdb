{# this removes all side-effect formatting from nested macros, producing a single line sql statement #}
{%- macro strip_to_single_line(str) -%}
    {{ str | replace('/*',' ') | replace('*/',' ') | replace('\n',' ') }}
{%- endmacro -%}
