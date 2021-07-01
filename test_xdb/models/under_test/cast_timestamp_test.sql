{{ config({"tags":["exclude_bigquery", "exclude_bigquery_tests"]}) }}

WITH
source_data AS (
    SELECT
        '2020-01-01' AS date_col
        , '2020-01-01 20:20:20' AS timestamp_col
)

SELECT
    {{xdb.cast_timestamp('date_col','timestamp_tz')}} AS date_tz
    , {{xdb.cast_timestamp('timestamp_col','timestamp_tz')}} AS tstamp_tz
{%- if target.type == 'bigquery' -%}
    /*{# BQ doesn't support timestamps without timezones #}*/
    ,date_col AS date_ntz
    ,timestamp_col AS tstamp_ntz
{%- else %}
    , {{xdb.cast_timestamp('date_col','timestamp_ntz')}} AS date_ntz
    , {{xdb.cast_timestamp('timestamp_col','timestamp_ntz')}} AS tstamp_ntz
{% endif -%}
FROM source_data
