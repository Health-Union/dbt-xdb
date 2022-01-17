{%- macro get_email_domain_extension(string) -%}
    {#/* Returns the domain extension of an email address (e.g. 'com', 'net', 'co.uk').
       ARGS:
         - string (string) email address to be processed.
       RETURNS: The requested part of an email address.
       SUPPORTS:
         - Postgres
         - Snowflake
    */#}
{%- if target.type ==  'postgres' -%}
SUBSTRING(SUBSTRING({{string}}, STRPOS({{string}}, '@') +1, LENGTH({{string}})), STRPOS(SUBSTRING({{string}}, STRPOS({{string}}, '@'), LENGTH({{string}})), '.'), LENGTH({{string}}))
   
{%- elif target.type == 'snowflake' -%}
SUBSTRING(SUBSTRING({{string}}, CHARINDEX('@', {{string}}) +1, LENGTH({{string}})), CHARINDEX('.', SUBSTRING({{string}}, CHARINDEX('@', {{string}}), LENGTH({{string}}))), LENGTH({{string}}))

{%- else -%}
    {{ xdb.not_supported_exception('get_email_domain_extension') }}
{%- endif -%}
{%- endmacro -%}
