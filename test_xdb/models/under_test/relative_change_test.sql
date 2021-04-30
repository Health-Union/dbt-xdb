
WITH
inputs AS (
    SELECT
        1 AS pos_1
        , 5 AS pos_2
        , -1 AS neg_1
        , -5 AS neg_2
        , 0 AS zero
        , 1.5 as dec_1
        , 2.25 as dec_2
        , 1.6 as dec_3
)
   
SELECT
    {{ xdb.relative_change("pos_1", "pos_2") }} as pos_pos_change
    , {{ xdb.percent_change("pos_1", "pos_2") }} as pos_pos_change_pct

    , {{ xdb.relative_change("neg_1", "neg_2") }} as neg_neg_change
    , {{ xdb.percent_change("neg_1", "neg_2") }} as neg_neg_change_pct

    , {{ xdb.relative_change("neg_1", "pos_1") }} as neg_pos_change
    , {{ xdb.percent_change("neg_1", "pos_1") }} as neg_pos_change_pct

    , {{ xdb.relative_change("pos_1", "neg_1") }} as pos_neg_change
    , {{ xdb.percent_change("pos_1", "neg_1") }} as pos_neg_change_pct

    , {{ xdb.relative_change("dec_1", "dec_2") }} as dec_dec_change
    , {{ xdb.percent_change("dec_1", "dec_2") }} as dec_dec_change_pct

    , {{ xdb.relative_change("pos_1", "dec_2") }} as pos_dec_change
    , {{ xdb.percent_change("pos_1", "dec_2") }} as pos_dec_change_pct

    , {{ xdb.relative_change("dec_3", "pos_1") }} as dec_pos_change
    , {{ xdb.percent_change("dec_3", "pos_1") }} as dec_pos_change_pct
FROM
   inputs
