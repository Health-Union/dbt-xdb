{%- macro aggregate_strings(val, delim) -%}
    {%- if target.type ==  'postgres' -%} 
        string_agg({{ val }}::varchar {{',' if delim else ''}}  {{ delim }})
    {%- elif target.type == 'bigquery' -%}
        string_agg(cast({{val}} as string) {{',' if delim else ''}}  {{ delim }})
    {%- elif target.type == 'snowflake' -%}
        listagg(cast({{ val }} as varchar){{',' if delim else ''}}  {{ delim }})
    {%- else -%}
        {{exceptions.raise_compiler_error("macro does not support aggregate_strings for target " ~ target.type ~ ".")}}
    {%- endif -%}
{%- endmacro -%}

