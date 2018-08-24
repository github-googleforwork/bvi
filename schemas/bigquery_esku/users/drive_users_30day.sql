-- drive_users_30day

SELECT
  DATE(YOUR_TIMESTAMP_PARAMETER) AS date,
  email
FROM (
  SELECT
    DATE(_PARTITIONTIME) AS date,
    email,
    NTH(2, SPLIT(email, '@')) AS domain
  FROM
    [YOUR_PROJECT_ID:EXPORT_DATASET.activity]
  WHERE
    record_type = 'drive'
    AND email <> ''
    AND drive.primary_event = true
    AND _PARTITIONTIME >= DATE_ADD(YOUR_TIMESTAMP_PARAMETER, -31, "DAY")
    AND _PARTITIONTIME < DATE_ADD(TIMESTAMP(YOUR_TIMESTAMP_PARAMETER),2,"DAY")
    AND TIMESTAMP(STRFTIME_UTC_USEC(time_usec,"%Y-%m-%d")) >= DATE_ADD(YOUR_TIMESTAMP_PARAMETER,-30,"DAY")
    AND TIMESTAMP(STRFTIME_UTC_USEC(time_usec,"%Y-%m-%d")) < DATE_ADD(YOUR_TIMESTAMP_PARAMETER,1,"DAY")
    ) drive_usage
WHERE
  domain IN ( YOUR_DOMAINS )
GROUP BY
  1,
  2