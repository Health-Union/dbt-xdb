{%- macro cast_json(val) -%}
    {# converts `val` to the basic json type in the target database
       ARGS:
         - val (string): the value to be cast/parsed
       RETURNS: The value typed as json
       SUPPORTS:
            - Postgres
            - Snowflake
    #}
    {%- if target.type ==  'postgres' -%} 
        {{val}}::jsonb
    {%- elif target.type == 'snowflake' -%}
        parse_json({{val}})
    {%- else -%}
        {{ xdb.not_supported_exception('cast_json') }}
    {%- endif -%}
{%- endmacro -%}
