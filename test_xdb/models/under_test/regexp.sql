WITH 
regexp as (
SELECT 
   CASE 
      WHEN {{xdb.regexp('company_name','^twitter','i')}} THEN company_name
      ELSE NULL END AS matches_twitter_at_start_case_insensitive
FROM
   prod.USER_BUSINESS
)
SELECT
    * 
FROM 
    regexp
WHERE 
    matches_twitter_at_start_case_insensitive
IS NOT NULL
