-- gmail_active_users_30day

SELECT
  date AS date,
  EXACT_COUNT_DISTINCT(email) AS count
FROM (
  SELECT
    DATE(_PARTITIONTIME) AS date,
    user_email AS email,
    NTH(2, SPLIT(user_email, '@')) AS domain
  FROM
    [YOUR_PROJECT_ID:Reports.usage]
  WHERE
    _PARTITIONTIME = TIMESTAMP(YOUR_TIMESTAMP_PARAMETER)
    AND record_type = 'user'
    AND SEC_TO_TIMESTAMP(gmail.last_interaction_time) >= DATE_ADD(TIMESTAMP(YOUR_TIMESTAMP_PARAMETER), -30, "DAY")
    AND gmail.last_interaction_time > 0) gmail_usage
WHERE
  domain IN ( YOUR_DOMAINS )
GROUP BY
  1