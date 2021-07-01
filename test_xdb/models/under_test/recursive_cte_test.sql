{{ config({"tags":["exclude_bigquery", "exclude_bigquery_tests"]}) }}

{%- if target.type == 'bigquery' -%}
    SELECT 'Bigquery Does Not Support Recursive CTEs' AS n

{%- else -%}
    {{ xdb.recursive_cte() }} cte_test(n)

AS (
    SELECT 0
    UNION ALL
    SELECT n + 1
    FROM cte_test
    WHERE n < 3
)

SELECT n
FROM cte_test

{% endif %}
