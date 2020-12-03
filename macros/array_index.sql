{%- macro array_index(index) -%}
  /*{# This macro takes a number and adjusts the index based on programming language. We use 0
        index because we're rational human beings
    ARGS:
        - Index (int) the 0 based index to convert
    RETURNS: The right position for the right database
    #}*/

    {%- if target.type == 'postgres' -%} 
	{{ (index + 1) }}
    {%- elif target.type == 'snowflake' -%}
    {{ index }}
    {%- elif target.type == 'bigquery' -%}
    offset({{ index }})
    {%- else -%}
        {{ xdb.not_supported_exception('any_value') }}
    {%- endif -%}
{%- endmacro -%}