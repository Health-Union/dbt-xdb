{{ config(tags=["exclude_bigquery_tests"]) }}
{% if target.type == 'bigquery' %}
    select 'Bigquery Does Not Support Recursive CTEs' as n

{% else %}

    {{ xdb.recursive_cte() }} cte_test(n) AS (
        SELECT 0

        UNION ALL

        SELECT n+1
        FROM cte_test
        where n < 3
    )

    SELECT n
    FROM cte_test

{% endif %}
