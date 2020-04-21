{% macro hash(fields, separator='-') -%}
    {# takes a list of column names to hash
        *Note* the fields will be sorted by name and concatenated as strings with a default '-' separator.
        ARGS:
            - fields (list) one of field names to hash together
        RETURNS: A string representing hash of given comments
    #}

    {%- set fields = fields | sort() -%}
    {%- if target.type == 'postgres'  -%}
        md5({{ xdb.concat(fields, separator) }})
    {%- elif target.type == 'snowflake' -%}
        md5({{ xdb.concat(fields, separator) }})
    {%- elif target.type == 'bigquery' -%}
        to_hex(md5({{ xdb.concat(fields, separator) }}))
    {%- else -%}
	   {{exceptions.raise_compiler_error("macro does not support regex strings for target " ~ target.type ~ ".")}}
    {%- endif -%}
{%- endmacro %}
