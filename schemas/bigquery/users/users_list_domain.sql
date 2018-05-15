-- users_list_domain
SELECT
  domain
FROM (
  SELECT
    HASH(primaryEmail) AS hash_value,
    IF(ABS(HASH(primaryEmail)) % 2 == 1, True, False) AS included_in_sample,
    NTH(2, SPLIT(primaryEmail, '@')) AS domain
  FROM
    [YOUR_PROJECT_ID:raw_data.users_list_date]
  LIMIT 100)
WHERE True
    AND included_in_sample
GROUP BY
  domain
HAVING count(*) > 5


