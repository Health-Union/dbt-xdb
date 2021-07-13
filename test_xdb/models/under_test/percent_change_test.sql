{{ config({"tags":["exclude_bigquery", "exclude_bigquery_tests"]}) }}
WITH inputs AS (
    SELECT
        1 AS pos_1
        , 5 AS pos_2
        , -1 AS neg_1
        , -5 AS neg_2
        , 0 AS zero
        , 1.5 AS dec_1
        , 2.25 AS dec_2
        , 1.6 AS dec_3
)

SELECT
    {{ xdb.percent_change("pos_1", "pos_2") }} AS pos_pos_change_pct
    , {{ xdb.percent_change("neg_1", "neg_2") }} AS neg_neg_change_pct
    , {{ xdb.percent_change("neg_1", "pos_1") }} AS neg_pos_change_pct
    , {{ xdb.percent_change("pos_1", "neg_1") }} AS pos_neg_change_pct
    , {{ xdb.percent_change("dec_1", "dec_2") }} AS dec_dec_change_pct
    , {{ xdb.percent_change("pos_1", "dec_2") }} AS pos_dec_change_pct
    , {{ xdb.percent_change("dec_3", "pos_1") }} AS dec_pos_change_pct
FROM
    inputs
