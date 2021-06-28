{% macro hash(fields) -%}
    {# takes a list of values to hash, coerces them to strings and hashes them.
        *Note* the fields will be sorted by name and concatenated as strings with a default '-' separator.
        ARGS:
            - fields (list) one of field names to hash together
        RETURNS: A string representing hash of `fields`
        SUPPORTS:
            - Postgres
            - Snowflake
            - BigQuery
    #}
    {%- set separator = '-' -%}
    {%- set fields = fields | sort() -%}
    {%- if target.type == 'postgres'  -%}
        MD5({{ xdb.concat(fields, separator) }})
    {%- elif target.type == 'snowflake' -%}
        md5({{ xdb.concat(fields, separator) }})
    {%- elif target.type == 'bigquery' -%}
        to_hex(md5({{ xdb.concat(fields, separator) }}))
    {%- else -%}
        {{ xdb.not_supported_exception('hash') }}
    {%- endif -%}
{%- endmacro %}
