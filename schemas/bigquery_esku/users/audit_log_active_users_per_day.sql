-- audit_log_active_users_per_day
SELECT
  date,
  email,
  COUNT(*) AS count
FROM (
  SELECT
    STRFTIME_UTC_USEC(time_usec,"%Y-%m-%d") AS date,
    LOWER(email) AS email,
    NTH(2, SPLIT(email, '@')) AS domain
  FROM
    [YOUR_PROJECT_ID:Reports.activity]
  WHERE
    record_type IN ('admin', 'drive', 'calendar', 'gplus')
    AND event_type IS NOT NULL
    AND email IS NOT NULL
    AND email <> ""
    AND _PARTITIONTIME >= DATE_ADD(YOUR_TIMESTAMP_PARAMETER, -1, "DAY")
    AND _PARTITIONTIME <= DATE_ADD(YOUR_TIMESTAMP_PARAMETER, 2,"DAY")
    AND DATE(STRFTIME_UTC_USEC(time_usec,"%Y-%m-%d")) = DATE(YOUR_TIMESTAMP_PARAMETER)) Audit_log
WHERE
  domain IN ( YOUR_DOMAINS )
GROUP BY 1, 2