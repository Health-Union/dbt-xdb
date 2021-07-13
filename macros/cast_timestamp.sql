{%- macro cast_timestamp(val, cast_as) -%}
    {#/* converts `val` to either a timestamp with timezone or a timestamp without timezone (per `cast_as`).
       ARGS:
         - val (identifier/date/timestamp) the value to be cast.  
         - cast_as (string) the destination data type, supported are `timestamp_tz` and `timestamp(_ntz)`
       RETURNS: The value typed as either timestamp or timestamp_ntz **with UTC time zone**
       SUPPORTS:
            - Postgres
            - Snowflake
            - BigQuery
    */#}
{%- set cast_as = cast_as |lower -%}
{%if cast_as not in ('timestamp','timestamp_ntz','timestamp_tz',) %}
    {{exceptions.raise_compiler_error("macro cast_timestamp for target does not support cast_as value " ~ cast_as)}}
{%- endif -%}

{%- if target.type ==  'postgres' -%} 
    {%- if cast_as in ('timestamp_ntz','timestamp') -%}
        {{val}}::TIMESTAMP
    {%- elif cast_as == 'timestamp_tz' -%}
        {{val}}::TIMESTAMP AT TIME ZONE 'UTC'
    {%- endif -%}

{%- elif target.type == 'bigquery' -%}
    {% if cast_as == 'timestamp_ntz' -%}
        {{exceptions.raise_compiler_error("BigQuery does not support timestamps without time zones.")}}
    {%- elif cast_as in ('timestamp','timestamp_tz',) -%}
        CAST({{val}} AS TIMESTAMP)
    {%- endif -%}

{%- elif target.type == 'snowflake' -%}
    {%- if cast_as in ('timestamp_ntz','timestamp') -%}
        {{val}}::TIMESTAMP_NTZ
    {%- elif cast_as == 'timestamp_tz' -%}
        TO_TIMESTAMP_TZ(TO_TIMESTAMP_NTZ({{val}})::VARCHAR || '+00', 'YYYY-MM-DD HH24:MI:SS.FFTZH')
    {%- endif %}

{%- else -%}
    {{ xdb.not_supported_exception('cast_timestamp') }}
{%- endif -%}
{%- endmacro -%}
a
