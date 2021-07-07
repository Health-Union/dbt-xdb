{%- set all_fields = ['date_col','int_col','email_col','text_col','float_col'] -%}
{%- set all_fields_order = ['text_col','date_col','email_col','float_col','int_col'] -%}
{%- set partial_fields = ['date_col','int_col','email_col','float_col'] -%}
{%- set has_null_field = ['int_col','null_col','text_col'] -%}
{%- set has_js_null_field = ['int_col','js_null_col','text_col'] -%}
WITH source_data AS (
    SELECT

        CAST('2020-01-01' AS date) AS date_col
        , CAST(1239 AS numeric) AS int_col
        , 'test@example.com' AS email_col
        , 'some-text, in here!' AS text_col
        , CAST(1.23 AS float{{ '64' if target.type == 'bigquery'}} ) AS float_col
        , CAST(NULL AS {{ 'STRING' if target.type == 'bigquery' else 'VARCHAR'}}) AS null_col
        {% if target.type == 'snowflake' -%}
            , parse_json('null')
        {%- elif target.type == 'postgres' -%}
            , to_jsonb('null'::VARCHAR)
        {%- else -%}
            , CAST('null' AS JSON)
        {%- endif %} AS js_null_col
)

SELECT
    {{ xdb.concat(all_fields) }} AS all_fields_no_sep
    , {{ xdb.concat(all_fields_order) }} AS all_fields_no_sep_dupe
    , {{ xdb.concat(all_fields, '-') }} AS all_fields_dash_sep
    , {{ xdb.concat(all_fields, '_') }} AS all_fields_lowdash_sep
    , {{ xdb.concat(all_fields, ',') }} AS all_fields_comma_sep
    , {{ xdb.concat(all_fields, ':') }} AS all_fields_colon_sep
    , {{ xdb.concat(partial_fields) }} AS partial_fields_no_sep
    , {{ xdb.concat(partial_fields, '-') }} AS partial_fields_dash_sep
    , {{ xdb.concat(has_null_field, '-') }} AS has_null_field
    , {{ xdb.concat(has_null_field, '-',false) }} AS all_null
    , {{ xdb.concat(has_js_null_field, '-') }} AS has_js_null_field
FROM
    source_data

