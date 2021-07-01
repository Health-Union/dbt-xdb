WITH
source_data AS (
    SELECT
        'abba is a great band' AS false_statement
        , 'https://www.cdc.gov/coronavirus/2019-ncov/index.html' AS covid_19_website
    {%- if target.type == 'postgres' -%}
            /*{# postgres needs to be told to apply C-style escapes. #}*/
        , E'¯\\_(ツ)_/¯ ' AS shrug_dude
    {%- else -%}
        , '¯\\_(ツ)_/¯ ' AS shrug_dude
    {%- endif %}
)

SELECT
    {{xdb.regexp_count('shrug_dude', "'\\\\'")}} AS finds_one
    , {{xdb.regexp_count('false_statement', "'b'")}} AS finds_three
    , {{xdb.regexp_count('covid_19_website', "'\d'")}} AS finds_four
FROM
    source_data
