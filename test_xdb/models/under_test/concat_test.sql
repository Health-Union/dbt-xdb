{%- set all_fields = ['date_col','int_col','email_col','text_col','float_col'] -%}
{%- set all_fields_order = ['text_col','date_col','email_col','float_col','int_col'] -%}
{%- set partial_fields = ['date_col','int_col','email_col','float_col'] -%}
{%- set has_null_field = ['int_col','null_col','text_col'] -%}
WITH source_data AS (
    SELECT
        cast('2020-01-01' as date) AS date_col
        , cast(1239 as numeric) as int_col
        , 'test@example.com' as email_col
        , 'some-text, in here!' as text_col
        , cast(1.23 as float{{ '64' if target.type == 'bigquery'}} ) as float_col
        ,cast(NULL AS {{ 'STRING' if target.type == 'bigquery' else 'VARCHAR'}}) as null_col
)
SELECT
    {{ xdb.concat(all_fields) }} as all_fields_no_sep
    , {{ xdb.concat(all_fields_order) }} as all_fields_no_sep_dupe
    , {{ xdb.concat(all_fields, '-') }} as all_fields_dash_sep
    , {{ xdb.concat(all_fields, '_') }} as all_fields_lowdash_sep
    , {{ xdb.concat(all_fields, ',') }} as all_fields_comma_sep
    , {{ xdb.concat(all_fields, ':') }} as all_fields_colon_sep
    , {{ xdb.concat(partial_fields) }} as partial_fields_no_sep
    , {{ xdb.concat(partial_fields, '-') }} as partial_fields_dash_sep
    , {{ xdb.concat(has_null_field,'-') }} as has_null_field
    , {{ xdb.concat(has_null_field,'-',false) }} as all_null
FROM
    source_data

