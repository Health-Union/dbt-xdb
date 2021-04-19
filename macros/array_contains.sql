{%- macro array_contains(array_values, contained_value) -%}
    {# This macro is used to determine if an array contains a certain value
        ARGS:
            - array_values (array) the array to check for the value
            - contained_value (string) the value to check the array for
        RETURNS: The appropriate sql syntax needed to check if the array contains the value
        SUPPORTS: 
            - Postgres
            - Snowflake

    #}

    {%- if target.type == 'postgres' -%} 
	    '{{ contained_value }}' = ANY({{ array_values }})
    {%- elif target.type == 'snowflake' -%}
        array_contains('{{ contained_value }}'::VARIANT, {{ array_values }})
    {%- else -%}
        {{ xdb.not_supported_exception('array_contains') }}
    {%- endif -%}
{%- endmacro -%}