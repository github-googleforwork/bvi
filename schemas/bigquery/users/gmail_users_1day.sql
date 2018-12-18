--gmail_users_1day
--review: 2017-10-30

SELECT
date as date,
email,
FROM (
  SELECT 
    DATE(_PARTITIONTIME) as date,
    entity.userEmail as email,
    NTH(2, SPLIT(entity.userEmail, '@')) AS domain
  FROM
    [YOUR_PROJECT_ID:raw_data.user_usage]
  WHERE
    parameters.name IN ("gmail:last_interaction_time")
    AND _PARTITIONTIME = TIMESTAMP(YOUR_TIMESTAMP_PARAMETER)
    AND parameters.datetimeValue >= TIMESTAMP(YOUR_TIMESTAMP_PARAMETER)
    ) gmail_usage
WHERE
  domain IN ( YOUR_DOMAINS )
GROUP BY 1, 2