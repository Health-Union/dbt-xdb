WITH
first_cte AS (
    SELECT
        1 AS id
        , 'banana' AS fruit
        , 'sock' AS clothing
)

, second_cte AS (
    SELECT
        1 AS id
        , 'banana' AS fruit
        , 'kaboom' AS batman_sound
        , 'bubbles' AS another_thing
    UNION ALL
    SELECT
        2 AS id
        , 'orange' AS fruit
        , 'kaboom' AS batman_sound
        , 'bubbles' AS another_thing
)

SELECT COUNT(*) AS number_of_rows
FROM {{xdb.using('first_cte',
            'second_cte',
            'fruit')}}

WHERE clothing = 'sock'


