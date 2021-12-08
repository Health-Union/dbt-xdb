{%- macro test_does_not_contain(model, substring, column_name) -%}
    {# tests that `substring` is not contained in `column_name`
        SUPPORTS:
            - Most (requires basic CTE support)
    #}
    SELECT
        *
    FROM
        {{model}}
    WHERE
        {{column_name}} like '%{{substring}}%'
{%- endmacro -%}
