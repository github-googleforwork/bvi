-- drive_users_30day
-- Review: 2017-11-21

SELECT
  DATE(YOUR_TIMESTAMP_PARAMETER) AS date,
  email
FROM (
  SELECT
    DATE(_PARTITIONTIME) AS date,
    (actor.email) AS email,
    NTH(2, SPLIT(actor.email, '@')) AS domain
  FROM
    [YOUR_PROJECT_ID:raw_data.audit_log]
  WHERE
    id.applicationName = 'drive'
    AND (actor.email) <> ''
    AND events.parameters.name = 'primary_event'
    AND _PARTITIONTIME >= DATE_ADD(TIMESTAMP(YOUR_TIMESTAMP_PARAMETER),-30,"DAY")
    AND _PARTITIONTIME < DATE_ADD(TIMESTAMP(YOUR_TIMESTAMP_PARAMETER),1,"DAY") 
    ) drive_usage
WHERE
  domain IN ( YOUR_DOMAINS )
GROUP BY
  1,
  2