{%- macro _regex_string_escape(pattern) -%}
    {#/* applies the weird escape sequences required for bigquery and snowflake
       ARGS:
         - pattern (string) the regex pattern to be escaped
       RETURNS: A properly escaped regex string
       SUPPORTS:
            - Postgres
            - Snowflake
            - BigQuery
    */#}
{%- if target.type == 'postgres'  -%} 
    {{pattern}}
{%- elif target.type == 'bigquery' -%}
    {{pattern}} 
{%- elif target.type == 'snowflake' -%}
    {{ pattern | replace('\\', '\\\\') }}
{%- else -%}
    {{ xdb.not_supported_exception('regex_string_escape') }}
{%- endif -%}

{%- endmacro -%}

{%- macro regexp(val,pattern,flag) -%}
    {#/*
        SUPPORTS:
            - Postgres
            - Snowflake
            - BigQuery
    */#}
{%- if target.type in ('postgres','redshift',) -%} 
'{{val}}' {{'~*' if flag == 'i' else '~'}} '{{xdb._regex_string_escape(pattern)}}'
{%- elif target.type == 'snowflake' -%}
    RLIKE('{{val}}', '{{xdb._regex_string_escape(pattern)}}', '{{args}}')
{%- elif target.type == 'bigquery' -%}
    REGEXP_CONTAINS('{{val}}', r'{{xdb._regex_string_escape(pattern)}}')
{%- else -%}
    {{ xdb.not_supported_exception('regexp') }}
{%- endif -%}

{%- endmacro -%}

{%- macro regexp_count(value, pattern) -%}
    {#/* counts how many instances of `pattern` in `value`
       ARGS:
         - value (string) the subject to be searched
         - pattern (string) the regex pattern to search for
       RETURNS: An integer count of patterns in value
       SUPPORTS:
            - Postgres
            - Snowflake
            - BigQuery
    */#}
{%- set pattern = xdb._regex_string_escape(pattern) -%}
{%- if target.type ==  'postgres' -%} 
    (SELECT COUNT(values)::INT FROM REGEXP_MATCHES({{value}}, {{pattern}}, 'g') AS values)
{%- elif target.type == 'bigquery' -%}
    (SELECT array_length(regexp_extract_all({{value}}, r{{pattern}})))
{%- elif target.type == 'snowflake' -%}
    REGEXP_COUNT({{value}},{{pattern}})
{%- else -%}
    {{ xdb.not_supported_exception('regexp_count') }}
{%- endif -%}
{%- endmacro -%}


{%- macro regexp_replace(val, pattern, replace) -%}
  {#/* replaces any matches of `pattern` in `val` with `replace`.
    NOTE: this will use native (database) regex matching, which may differ from db to db.
    ARGS:
        - val (string/column) the value to search for `pattern`.
        - pattern (string) the native regex pattern to search for.
        - replace (string) the string to insert in place of `pattern`. 
    RETURNS: the updated string. 
    SUPPORTS:
        - Postgres
        - Snowflake
        - BigQuery
  */#}
{%- set pattern = xdb._regex_string_escape(pattern) -%}
{%- if target.type in ('postgres','snowflake',) -%}
    REGEXP_REPLACE( {{ val }}, {{ pattern }}, {{ replace }})
{%- else -%}
    {{ xdb.not_supported_exception('regexp_replace') }}
{%- endif -%}
{%- endmacro -%}