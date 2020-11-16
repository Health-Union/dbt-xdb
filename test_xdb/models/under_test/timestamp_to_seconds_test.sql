WITH
    test_data AS (
    SELECT 
        '1980-01-01 00:00:000'::timestamp AS test_timestamp
)

SELECT 
    {{ xdb.timestamp_to_seconds("test_timestamp") }} AS seconds_in_seventies
FROM
   test_data
