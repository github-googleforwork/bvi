-- gmail_active_users_30day
-- Review: 2017-11-10

SELECT
  date AS date,
  EXACT_COUNT_DISTINCT(email) AS count
FROM (
  SELECT
    DATE(_PARTITIONTIME) AS date,
    entity.userEmail AS email,
    NTH(2, SPLIT(entity.userEmail, '@')) AS domain
  FROM
    [YOUR_PROJECT_ID:raw_data.user_usage]
  WHERE
    parameters.name IN ("gmail:last_interaction_time")
    AND _PARTITIONTIME = TIMESTAMP(YOUR_TIMESTAMP_PARAMETER)
    AND parameters.datetimeValue >= DATE_ADD(TIMESTAMP(YOUR_TIMESTAMP_PARAMETER), -30, "DAY")) gmail_usage
WHERE
  domain IN (
  SELECT
    domain
  FROM
    [YOUR_PROJECT_ID:users.users_list_domain] )
GROUP BY
  1