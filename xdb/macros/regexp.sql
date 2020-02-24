{%- macro regex_string_escape(string) -%}

    {%- if target.type in ('postgres', 'redshift',)  -%} 
       {{string}} 
    {%- elif target.type == 'bigquery' -%}
       {{ string | replace('\\', '\\\\') }}
    {%- elif target.type == 'snowflake' -%}
       {{ string | replace('\\', '\\\\') }}
    {%- else -%}
	   {{exceptions.raise_compiler_error("macro does not support regex strings for target " ~ target.type ~ ".")}}
    {%- endif -%}

{%- endmacro -%}

{%- macro regexp(val,pattern,flag) -%}
    {%- if target.type in ('postgres','redshift',) -%} 
	'{{val}}' {{'~*' if flag == 'i' else '~'}} '{{xdb.regex_string_escape(pattern)}}'
    {%- elif target.type == 'snowflake' -%}
        rlike('{{val}}', '{{xdb.regex_string_escape(pattern)}}', '{{args}}')
    {%- elif target.type == 'bigquery' -%}
        regexp_contains('{{val}}', r'{{xdb.regex_string_escape(pattern)}}')
    {%- else -%}
	{{exceptions.raise_compiler_error("macro does not support regexp for target " ~ target.type ~ ".")}}
    {%- endif -%}
    
{%- endmacro -%}
