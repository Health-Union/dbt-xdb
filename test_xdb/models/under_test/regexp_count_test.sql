WITH
source_data AS (
    SELECT --noqa:L036
        'abba is a great band' AS false_statement
        , 'https://www.cdc.gov/coronavirus/2019-ncov/index.html' AS covid_19_website
    {%- if target.type == 'postgres' -%}
            /*{# postgres needs to be told to apply C-style escapes. #}*/
        , E'¯\\_(ツ)_/¯ ' AS shrug_dude --noqa
    {%- else -%}
        , '¯\\_(ツ)_/¯ ' AS shrug_dude
    {%- endif %}
)

SELECT
    {{xdb.regexp_count('shrug_dude', "'\\\\'")}} AS finds_one --noqa:L025,L029
    , {{xdb.regexp_count('false_statement', "'b'")}} AS finds_three --noqa:L025,L029
    , {{xdb.regexp_count('covid_19_website', "'\d'")}} AS finds_four --noqa:L025,L029
FROM
    source_data
