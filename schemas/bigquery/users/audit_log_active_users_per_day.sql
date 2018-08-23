-- audit_log_active_users_per_day
-- Review: 23/02/2017
SELECT
  date AS date,
  email,
  COUNT(*) AS count
FROM (
  SELECT
    STRFTIME_UTC_USEC(id.time,"%Y-%m-%d") AS date,
    LOWER(actor.email) AS email,
    NTH(2, SPLIT(actor.email, '@')) AS domain,
  FROM
    [YOUR_PROJECT_ID:raw_data.audit_log]
  WHERE
    events.type IS NOT NULL
    AND actor.email IS NOT NULL
    AND actor.email <> ""
    AND _PARTITIONTIME = YOUR_TIMESTAMP_PARAMETER) Audit_log
WHERE
  domain IN ( YOUR_DOMAINS )
GROUP BY 1, 2