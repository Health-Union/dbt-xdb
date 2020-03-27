WITH
source_data AS (
    SELECT
        'abba is a great band' AS false_statement
        ,'https://www.cdc.gov/coronavirus/2019-ncov/index.html' AS covid_19_website
        ,'¯\\_(ツ)_/¯' AS shrug_dude
)
   
SELECT
    {{xdb.regexp_count('shrug_dude',"'\\\\'")}} AS finds_one
    ,{{xdb.regexp_count('false_statement', "'b'")}} AS finds_three
    ,{{xdb.regexp_count('covid_19_website',"'\d'")}} AS finds_four
FROM
    source_data
