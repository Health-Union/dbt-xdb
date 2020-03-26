{%- macro dateadd(part, amount_to_add, value) -%}
    {# adds `amount_to_add` `part`s to `value`. so adding one day to Jan 1 2020 would be dateadd('day',1,'2020-01-01'). 
       NOTE: dateadd only manipulates date values. for time additions see [timeadd](#timeadd) 
       ARGS:
         - part (string) one of 'day','week','month','year'.  
         - amount_to_add (int) number of `part` units to add to `value`. Negative subtracts.
         - value (string) the date string or column to add to.
       RETURNS: a date value with the amount added.
    #}
    {%- set part = part |lower -%}
    {%if part not in ('day','week','month','year',) %}
        {% if part in ('hour','minute','second',) %}
            {{exceptions.raise_compiler_error("time component passed to macro `dateadd()`. Did you want `timeadd()`?")}}
        {% endif %}
        {{exceptions.raise_compiler_error("macro dateadd for target does not support part value " ~ cast_as)}}
    {%- endif -%}

    {%- if target.type ==  'postgres' -%} 
        {{value}}::DATE + {{amount_to_add}} * INTERVAL '1 {{part}}'

    {%- elif target.type == 'bigquery' -%}
        DATE_ADD(CAST({{value}} AS DATE), INTERVAL {{amount_to_add}} {{part|upper}})
    {%- elif target.type == 'snowflake' -%}
        
    {%- else -%}
        {{exceptions.raise_compiler_error("macro does not support dateadd for target " ~ target.type ~ ".")}}
    {%- endif -%}
{%- endmacro -%}

