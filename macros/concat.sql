{% macro concat(fields, separator='', convert_null=true) -%}
    {# takes a list of column names to concatenate and an optional separator
    ARGS:
        - fields (list) one of field names to hash together
        - separator (string) a string value to separate field values with. defaults to an empty space
        - null_representation (string) defines how NULL values are passed to the target. Default is the string 'NULL'. 
    RETURNS: A string representing hash of given comments
    SUPPORTS:
        - Postgres
        - Snowflake
        - BigQuery
    #}

    {%- set sep_text = xdb._concat_separator_text(separator) -%}
    {%- set casted_fields = xdb._concat_cast_fields(fields, convert_null) -%}

    {%- if target.type in ('postgres','bigquery',)  -%}
        CONCAT({{ casted_fields | join(sep_text) }})
    {%- elif target.type == 'snowflake' -%}
        concat_ws( '{{ separator }}', {{ casted_fields | join(', ') }})
    {%- else -%}
        {{ xdb.not_supported_exception('concat') }}
    {%- endif -%}
{%- endmacro %}

{% macro _concat_separator_text(separator) -%}
    {#
        SUPPORTS:
            - All
    #}
    , {{ "'" ~ separator ~ "', " if separator != '' }}
{%- endmacro %}

{% macro _concat_cast_fields(fields, convert_null) -%}
    {#
        SUPPORTS:
            - Postgres
            - Snowflake
            - BigQuery
    #}
    {%- set casted_fields = [] -%}
    {%- for field in fields -%}
        {%- if target.type in ('postgres','snowflake',)  -%}
            {%- if convert_null -%}
                {%- set field_casted = "CASE WHEN " ~ field ~ " IS NULL THEN 'NULL'::VARCHAR ELSE " ~ field ~ "::VARCHAR END" -%}
            {%- else -%}
                {%- set field_casted = field ~ "::VARCHAR" -%}
            {%- endif -%}
        {%- elif target.type == 'bigquery' -%}
            {%- if convert_null -%}
                {%- set field_casted = "CASE WHEN " ~ field ~ " IS NULL THEN CAST('NULL' AS STRING) ELSE CAST(" ~ field ~ " AS STRING) END" -%}
            {%- else -%}
                {%- set field_casted = "CAST(" ~ field ~ " AS STRING)"-%}
            {%- endif -%}
        {%- endif -%}
        {% set _ = casted_fields.append(field_casted) %}
    {%- endfor -%}
    {{ return(casted_fields) }}
{%- endmacro %}