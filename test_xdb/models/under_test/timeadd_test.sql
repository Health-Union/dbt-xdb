WITH 
source_data AS (
SELECT
    '2020-01-01 00:00:00' AS date_col
)
SELECT
    {{xdb.dateadd('day','1', 'date_col')}} as one_second_added
    ,{{xdb.dateadd('day','-1', 'date_col')}} as one_second_subtracted
    ,{{xdb.dateadd('week','1', 'date_col')}} as one_minute_added
    ,{{xdb.dateadd('week','-1', 'date_col')}} as one_minute_subtracted
    ,{{xdb.dateadd('month','1', 'date_col')}} as one_hour_added
    ,{{xdb.dateadd('month','-1', 'date_col')}} as one_hour_subtracted
FROM
    source_data

