
WITH 
source_data AS (
SELECT
    '2020-01-01' AS date_col
)
SELECT
    {{xdb.dateadd('day','1', 'date_col')}} as one_day_added
    ,{{xdb.dateadd('day','-1', 'date_col')}} as one_day_subtracted
    ,{{xdb.dateadd('week','1', 'date_col')}} as one_week_added
    ,{{xdb.dateadd('week','-1', 'date_col')}} as one_week_subtracted
    ,{{xdb.dateadd('month','1', 'date_col')}} as one_month_added
    ,{{xdb.dateadd('month','-1', 'date_col')}} as one_month_subtracted
FROM
    source_data

