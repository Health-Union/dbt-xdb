
WITH 
source_data AS (
SELECT
    '2020-01-01' AS date_col
)
SELECT
    {{xdb.dateadd('days','1', 'date_col')}} as one_day_add
    ,{{xdb.dateadd('days','1', 'date_col')}} as one_day_subtract
FROM
    source_data

