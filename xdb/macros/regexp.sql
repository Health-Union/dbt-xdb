{%- macro regex_string_escape(string) -%}

    {%- if target.type in ('postgres', 'redshift', 'bigquery',)  -%} 
       {{string}} 
    {%- elif target.type == 'snowflake' -%}
       {{ string | replace('\\', '\\\\') }}
    {%- else -%}
	   {{exceptions.raise_compiler_error("macro does not support regex strings for target " ~ target.type ~ ".")}}
    {%- endif -%}

{%- endmacro -%}

{%- macro regexp(val,pattern,flag) -%}
    {%- if target.type == 'postgres' -%} 
	'{{val}}' {{'~*' if flag == 'i' else '~'}} '{{xdb.regex_string_escape(pattern)}}'
    {%- elif target.type == 'snowflake' -%}
        rlike('{{val}}', '{{xdb.regex_string_escape(pattern)}}', '{{args}}')
    {%- else -%}
	{{exceptions.raise_compiler_error("macro does not support regexp for target " ~ target.type ~ ".")}}
    {%- endif -%}
    
{%- endmacro -%}
