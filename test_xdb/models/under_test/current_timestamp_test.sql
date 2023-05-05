WITH timestamp_tz AS (
    {%- if target.type == 'postgres' -%}
        SELECT PG_TYPEOF({{ xdb.current_timestamp() }})::varchar AS test_timestamp_with_timezone
    {%- elif target.type == 'snowflake' -%}
        SELECT TYPEOF(
            TO_VARIANT({{ xdb.current_timestamp() }})
        ) AS test_timestamp_with_timezone
    {%- endif -%}
)

SELECT 'true' AS result
FROM timestamp_tz
WHERE test_timestamp_with_timezone in ('TIMESTAMP_LTZ', 'timestamp with time zone')
