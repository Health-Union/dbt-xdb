
WITH
source_data AS (
    SELECT '2020-01-01' AS date_col
)

SELECT
    {{xdb.dateadd('day', '1', 'date_col')}} AS one_day_added
    , {{xdb.dateadd('day', '-1', 'date_col')}} AS one_day_subtracted
    , {{xdb.dateadd('week', '1', 'date_col')}} AS one_week_added
    , {{xdb.dateadd('week', '-1', 'date_col')}} AS one_week_subtracted
    , {{xdb.dateadd('month', '1', 'date_col')}} AS one_month_added
    , {{xdb.dateadd('month', '-1', 'date_col')}} AS one_month_subtracted
    , {{xdb.dateadd('year',' 1', 'date_col')}} AS one_year_added
    , {{xdb.dateadd('year',' -1', 'date_col')}} AS one_year_subtracted
FROM
    source_data

