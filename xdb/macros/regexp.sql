{%- macro regexp(val,pattern,flag) -%}
    {%- if target.type == 'postgres' -%} 
	'{{val}}' {{'~*' if flag == 'i' else '~'}} '{{pattern}}'
    {%- elif target.type == 'snowflake' -%}
        rlike('{{val}}','{{args}}')
    {%- else -%}
	{{exceptions.raise_compiler_error("macro does not support regexp for target " ~ target.type ~ ".")}}
    {%- endif -%}
    
{%- endmacro -%}
