{%- set all_fields = ['date_col','int_col','email_col','text_col','float_col'] -%}
{%- set all_fields_order = ['text_col','date_col','email_col','float_col','int_col'] -%}
{%- set partial_fields = ['date_col','int_col','email_col','float_col'] -%}

WITH source_data AS (
    SELECT
        cast('2020-01-01' as date) AS date_col
        , cast(1239 as int) as int_col
        , 'test@example.com' as email_col
        , 'some-text, in here!' as text_col
        , cast(1.23 as float) as float_col
)
SELECT
    {{ xdb.hash(all_fields, '') }} as all_fields_no_sep
    , {{ xdb.hash(all_fields_order, '') }} as all_fields_no_sep_dupe
    , {{ xdb.hash(all_fields, '-') }} as all_fields_dash_sep
    , {{ xdb.hash(all_fields, '_') }} as all_fields_lowdash_sep
    , {{ xdb.hash(all_fields, ',') }} as all_fields_comma_sep
    , {{ xdb.hash(all_fields, ':') }} as all_fields_colon_sep
    , {{ xdb.hash(partial_fields, '') }} as partial_fields_no_sep
    , {{ xdb.hash(partial_fields, '-') }} as partial_fields_dash_sep
FROM
    source_data

