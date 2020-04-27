{% macro concat(fields, separator='') -%}
  /*{# takes a list of column names to concatenate and an optional separator
    ARGS:
        - fields (list) one of field names to hash together
        - separator a string value to separate field values with. defaults to an empty space
    RETURNS: A string representing hash of given comments
    #}*/

    {%- set sep_text = xdb._concat_separator_text(separator) -%}
    {%- set casted_fields = xdb._concat_cast_fields(fields) -%}

    {%- if target.type == 'postgres'  -%}
        concat({{ casted_fields | join(sep_text) }})
    {%- elif target.type == 'snowflake' -%}
        concat_ws( '{{ separator }}', {{ casted_fields | join(', ') }})
    {%- elif target.type == 'bigquery' -%}
        concat({{ casted_fields | join(sep_text) }})
    {%- else -%}
        {{ xdb.not_supported_exception('concat') }}
    {%- endif -%}
{%- endmacro %}

{% macro _concat_separator_text(separator) -%}
    , {{ "'" ~ separator ~ "', " if separator != '' }}
{%- endmacro %}

{% macro _concat_cast_fields(fields) -%}
    {%- set casted_fields = [] -%}
    {%- for field in fields -%}
        {%- if target.type == 'postgres'  -%}
            {%- set field_casted = field ~ '::varchar' -%}
        {%- elif target.type == 'snowflake' -%}
            {%- set field_casted = field ~ '::varchar' -%}
        {%- elif target.type == 'bigquery' -%}
            {%- set field_casted = 'CAST(' ~ field ~ ' AS STRING)' -%}
        {%- endif -%}
        {% set _ = casted_fields.append(field_casted) %}
    {%- endfor -%}
    {{ return(casted_fields) }}
{%- endmacro %}