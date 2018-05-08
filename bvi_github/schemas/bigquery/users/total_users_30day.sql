--total_users_30day
--review: 2017-12-04

SELECT
  DATE(YOUR_TIMESTAMP_PARAMETER) AS date,
  EXACT_COUNT_DISTINCT(email) AS count
FROM (
  SELECT
    DATE(_PARTITIONTIME) AS date,
    entity.userEmail AS email,
    NTH(2, SPLIT(entity.userEmail, '@')) AS domain
  FROM
    [YOUR_PROJECT_ID:raw_data.user_usage]
  WHERE
    _PARTITIONTIME >= DATE_ADD(TIMESTAMP(YOUR_TIMESTAMP_PARAMETER), -30, "DAY")
    AND _PARTITIONTIME < DATE_ADD(TIMESTAMP(YOUR_TIMESTAMP_PARAMETER), 1, "DAY")
    AND parameters.name= 'accounts:is_suspended'
    AND parameters.boolValue= FALSE) user_usage
WHERE
  domain IN (
  SELECT
    domain
  FROM
    [YOUR_PROJECT_ID:users.users_list_domain] )
GROUP BY
  1
ORDER BY
  1 DESC