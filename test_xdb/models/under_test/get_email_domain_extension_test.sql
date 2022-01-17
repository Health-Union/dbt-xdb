{{ config(tags=["exclude_bigquery","exclude_bigquery_tests"]) }}

WITH
source_data AS (
    SELECT
        'john.doe@dummy.com' AS username_w_dot_com_data
	, 'johndoe@dummy.net' AS username_wo_dot_net_data
	, 'john.doe@dummy.co.uk' AS username_w_dot_co_uk_data
	, 'johndoe@dummy.com.ar' AS username_wo_dot_com_ar_data
)

SELECT
    {{ xdb.get_email_domain_extension('username_w_dot_com_data') }} AS username_w_dot_com
    , {{ xdb.get_email_domain_extension('username_wo_dot_net_data') }} AS username_wo_dot_net
    , {{ xdb.get_email_domain_extension('username_w_dot_co_uk_data') }} AS username_w_dot_co_uk
    , {{ xdb.get_email_domain_extension('username_wo_dot_com_ar_data') }} AS username_wo_dot_com_ar
FROM
    source_data
