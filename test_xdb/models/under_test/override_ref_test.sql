WITH unioned_data AS (
    SELECT status FROM {{ xdb.override_ref('override_ref_test_model_table') }}
    UNION ALL
    SELECT status FROM {{ xdb.override_ref('override_ref_test_model_view_based_on_table') }}
    UNION ALL
    SELECT status FROM {{ xdb.override_ref('override_ref_test_model_view_based_on_view') }}
)

SELECT
    SUM(status) AS reached_objects_count
FROM unioned_data