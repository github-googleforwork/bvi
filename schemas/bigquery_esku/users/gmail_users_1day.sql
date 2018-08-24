--gmail_users_1day

SELECT
date as date,
email,
FROM (
  SELECT
    DATE(_PARTITIONTIME) AS date,
    user_email AS email,
    NTH(2, SPLIT(user_email, '@')) AS domain
  FROM
    [YOUR_PROJECT_ID:EXPORT_DATASET.usage]
  WHERE
    _PARTITIONTIME = TIMESTAMP(YOUR_TIMESTAMP_PARAMETER)
    AND record_type = 'user'
    AND SEC_TO_TIMESTAMP(gmail.last_interaction_time) >= TIMESTAMP(YOUR_TIMESTAMP_PARAMETER)
    AND SEC_TO_TIMESTAMP(gmail.last_interaction_time) < DATE_ADD(TIMESTAMP(YOUR_TIMESTAMP_PARAMETER),1,"DAY")
    AND gmail.last_interaction_time > 0
    ) gmail_usage
WHERE
  domain IN ( YOUR_DOMAINS )
GROUP BY 1, 2