{%- set all_fields = ['date_col','int_col','email_col','text_col','float_col'] -%}
{%- set all_fields_order = ['text_col','date_col','email_col','float_col','int_col'] -%}
{%- set partial_fields = ['date_col','int_col','email_col','float_col'] -%}

WITH source_data AS (
    SELECT
        CAST('2020-01-01' AS date) AS date_col
        , CAST(1239 AS numeric) AS int_col
        , 'test@example.com' AS email_col
        , 'some-text, in here!' AS text_col
        , CAST(1.23 AS float{{ '64'if target.type == 'bigquery' }} ) AS float_col
)

SELECT
    {{ xdb.hash(all_fields) }} AS all_fields
    , {{ xdb.hash(all_fields_order) }} AS all_fields_reordered
    , {{ xdb.hash(partial_fields) }} AS partial_fields
FROM
    source_data

