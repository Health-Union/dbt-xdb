{%- macro quote_insensitive(identifier) -%}
    {# Correctly quotes identifers to match the native folding for the target data warehouse.
       Per the SQL spec this _should_ be to uppercase, but this is not always the standard. 
       ARGS:
         - identifier (string) the column / database / relation name to be folded and quoted.
       RETURNS: The `identifier` value correctly folded **and wrapped in double quotes**.
    #}
    {%- if target.type ==  'postgres' -%} 
        "{{identifier|lower}}"
    {%- elif target.type in ('bigquery','snowflake',) -%}
        "{{identifier|lower}}"
    {%- endif -%}
{%- endmacro -%}

