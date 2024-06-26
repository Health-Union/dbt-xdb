{%- macro split_part(string, delimiter, position) -%}
    {#/* ports SPLIT_PART function, that splits a string on a specified delimiter and returns the nth substring.
       ARGS:
         - string (string) text to be split into parts.
         - delimiter (string) text representing the delimiter to split by.
         - position (int) requested part of the split (1-based). If the value is negative, the parts are counted backward from the end of the string.
       RETURNS: The requested part of a string.
       SUPPORTS:
         - Postgres
         - Snowflake
    */#}
{%- if target.type ==  'postgres' -%}
    {%- if position < 0 -%} 
        {% set position = position * -1 %}
        REVERSE(SPLIT_PART(REVERSE({{string}}), {{delimiter}}, {{position}}))
    {%- else -%}
        SPLIT_PART({{string}}, {{delimiter}}, {{position}})
    {%- endif -%}

{%- elif target.type == 'snowflake' -%}
    SPLIT_PART({{string}}, {{delimiter}}, {{position}})

{%- else -%}
    {{ xdb.not_supported_exception('split_part') }}
{%- endif -%}
{%- endmacro -%}
