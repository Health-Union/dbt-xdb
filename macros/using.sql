{%- macro using(rel_1,rel_2,col) -%}
    {%- if target.type in ('postgres','redshift','bigquery','snowflake',) -%} 
	    {{rel_1}} JOIN {{rel_2}} USING ({{col}})
    {%- else -%}
        {{ xdb.not_supported_exception('using') }}
    {%- endif -%}
{%- endmacro -%}

