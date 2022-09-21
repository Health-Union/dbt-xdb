{%- macro get_quoted_column_name(identifier) -%}
{%- if target.type == 'postgres' -%}
"{{ identifier | lower }}" 
{%- else -%}
"{{ identifier | upper }}"
{%- endif -%}
{%- endmacro -%}