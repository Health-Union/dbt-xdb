{%- macro using(rel_1,rel_2,col) -%}
    {%- if target.type in ('postgres','redshift','bigquery','snowflake',) -%} 
	    {{rel_1}} JOIN {{rel_2}} USING ({{col}})
    {%- else -%}
	{{exceptions.raise_compiler_error("macro does not support any_value for target " ~ target.type ~ ".")}}
    {%- endif -%}
{%- endmacro -%}

