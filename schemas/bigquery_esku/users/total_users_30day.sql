--total_users_30day

SELECT
  DATE(YOUR_TIMESTAMP_PARAMETER) AS date,
  EXACT_COUNT_DISTINCT(email) AS count
FROM (
  SELECT
    DATE(_PARTITIONTIME) AS date,
    user_email AS email,
    NTH(2, SPLIT(user_email, '@')) AS domain
  FROM
    [YOUR_PROJECT_ID:EXPORT_DATASET.usage]
  WHERE
    _PARTITIONTIME >= DATE_ADD(TIMESTAMP(YOUR_TIMESTAMP_PARAMETER), -30, "DAY")
    AND _PARTITIONTIME < DATE_ADD(TIMESTAMP(YOUR_TIMESTAMP_PARAMETER), 1, "DAY")
    AND accounts.is_suspended = false
    AND record_type = 'user') user_usage
WHERE
  domain IN ( YOUR_DOMAINS )
GROUP BY
  1
ORDER BY
  1 DESC