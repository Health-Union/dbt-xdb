{{ config({"tags":["exclude_bigquery", "exclude_bigquery_tests"]}) }}
WITH
source_data AS (
    SELECT
        'No mister Bond, I expect you to live!' AS goldfinger
        ,'   three   spaces' AS three_spaces
        ,'https://health-union.com' AS ssh_url
)
   
SELECT
    {{xdb.regexp_replace('goldfinger',"'live'","'die'")}} AS corrects_quote
    ,{{xdb.regexp_replace('three_spaces', "'\s{3}three\s{3}'", "'  two  '")}} AS finds_two
    ,{{xdb.regexp_replace('ssh_url',"'https\:\/\/'", "'http://'")}} AS finds_insecure
FROM
    source_data
