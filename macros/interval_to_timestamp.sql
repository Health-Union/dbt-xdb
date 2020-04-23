{%- macro interval_to_timestamp(part, val) -%}
    {# converts and interval `val` to a timestamp
       *Note* the order of left_val, right_val is reversed from Snowflake.
       ARGS:
         - part (string) one of 'second', 'minute'
         - val (integer representing a unit of time) the value 
       RETURNS: A string representing the time in HH24:MM:SS format
    #}
    {%- set part = part |lower -%}
    {%if part not in ('second', 'minute',) %}
        {{exceptions.raise_compiler_error("macro interval_to_timestamp for target does not support date part value " ~ part)}}
    {%- endif -%}

    {%- if target.type ==  'postgres' -%} 
        TO_CHAR(CONCAT({{ val }}::VARCHAR, '{{ part }}')::interval, 'HH24:MI:SS')


    {%- elif target.type == 'bigquery' -%}
        {% if part == 'second' %}
            case when floor({{ val }} / 3600) < 10 then
                concat(lpad(cast(floor({{ val }} / 3600) as string), 2, '0'), ':', 
                lpad(cast(mod(cast(floor({{ val }} / 60) as int64),60) as string), 2, '0'), ':', 
                lpad(cast(mod({{ val }}, 60) as string), 2, '0'))
            else 
                concat(cast(floor({{ val }} / 3600) as string), ':', 
                lpad(cast(mod(cast(floor({{ val }} / 60) as int64),60) as string), 2, '0'), ':', 
                lpad(cast(mod({{ val }}, 60) as string), 2, '0'))
            end

        {% elif part == 'minute' %}
            case when floor({{ val }} / 60) < 10 then
                concat(lpad(cast(floor({{ val }} / 60) as string), 2, '0'), ':', 
                lpad(cast(mod({{ val }}, 60) as string), 2, '0'), ':00')
            else 
                concat(cast(floor({{ val }} / 60) as string), ':', 
                lpad(cast(mod({{ val }}, 60) as string), 2, '0'), ':00')
            end
        {%- endif %}

    {%- elif target.type == 'snowflake' -%}
        {% if part == 'second' %}
            case when floor({{ val }} / 3600) < 10 then 
                    concat(lpad(floor({{ val }} / 3600),2,0), ':', 
                        lpad(floor(({{ val }} / 60) % 60),2,0), ':', 
                        lpad(floor({{ val }} % 60),2,0))
                else 
                    concat(floor({{ val }} / 3600), ':', 
                        lpad(floor(({{ val }} / 60) % 60),2,0), ':', 
                        lpad(floor({{ val }} % 60),2,0))
                end 

        {% elif part == 'minute' %}
            case when floor({{ val }} / 60) < 10 then 
                    concat(lpad(floor({{ val }} / 60),2,0), ':', lpad(floor({{ val }} % 60),2,0), ':00')
                else 
                    concat(floor({{ val }} / 60), ':', lpad(floor({{ val }} % 60),2,0), ':00')
                end 
        {%- endif %}

    {%- else -%}
        {{ xdb.not_supported_exception('interval_to_timestamp') }}
    {%- endif -%}
{%- endmacro -%}
