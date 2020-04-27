{%- macro any_value(val) -%}
    {%- if target.type in ('postgres','redshift',) -%} 
	max('{{val}}') 
    {%- elif target.type in ('snowflake','bigquery',) -%}
        any_value('{{val}}')
    {%- else -%}
        {{ xdb.not_supported_exception('any_value') }}
    {%- endif -%}
{%- endmacro -%}

