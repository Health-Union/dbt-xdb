{%- macro aggregate_strings(val, delim) -%}
    {%- if target.type in ('bigquery','postgres',) -%} 
        string_agg({{ val }}::varchar, {{ delim }})
    {%- elif target.type in ('redshift','snowflake',) -%}
        listagg({{ val }}::varchar, {{ delim }})
    {%- else -%}
        {{exceptions.raise_compiler_error("macro does not support aggregate_strings for target " ~ target.type ~ ".")}}
    {%- endif -%}
{%- endmacro -%}

