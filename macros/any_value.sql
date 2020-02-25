{%- macro any_value(val) -%}
    {%- if target.type in ('postgres','redshift',) -%} 
	max('{{val}}') 
    {%- elif target.type in ('snowflake','bigquery',) -%}
        any_value('{{val}}')
    {%- else -%}
	{{exceptions.raise_compiler_error("macro does not support any_value for target " ~ target.type ~ ".")}}
    {%- endif -%}
{%- endmacro -%}

