WITH timestamp_ntz AS (
    {%- if target.type == 'postgres' -%}
        SELECT PG_TYPEOF({{ xdb.current_timestamp_ntz() }})::varchar AS test_timestamp_without_timezone
    {%- elif target.type == 'snowflake' -%}
        SELECT TYPEOF(
            TO_VARIANT({{ xdb.current_timestamp_ntz() }})
        ) AS test_timestamp_without_timezone
    {%- endif -%}
)

SELECT 'true' AS result
FROM timestamp_ntz
WHERE test_timestamp_without_timezone in ('TIMESTAMP_NTZ', 'timestamp without time zone')
