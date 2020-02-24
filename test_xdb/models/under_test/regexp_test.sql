WITH
banana_urls AS (
    SELECT
        'https://www.banana.com/landing-page/subpage?query=thing' AS url
    UNION ALL
    SELECT
        'https://www.hotdog.com/landing-page/subpage?query=thing' AS url
    UNION ALL
    SELECT
        'https://www.banana.com?query=thing' AS url
    UNION ALL
    SELECT
        'www.banana.com/other-page' AS url
)
   
SELECT
   CASE
      WHEN {{xdb.regexp('url','(http://|https://)?banana.COM(/(\w*)?)?','i')}} THEN url
      ELSE NULL
   END AS banana_domain
  ,CASE
      WHEN {{xdb.regexp('url','(http://|https://)?banana.com/landing-page(\w*)?')}} THEN URL
   ELSE NULL
   END AS landing_page_url
FROM
   banana_urls
