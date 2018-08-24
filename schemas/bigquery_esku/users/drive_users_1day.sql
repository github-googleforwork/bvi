--drive_users_1day

SELECT
  date AS date,
  email
FROM (
  SELECT  
    DATE(_PARTITIONTIME) AS date, 
    email,
    NTH(2, SPLIT(email, '@')) AS domain
  FROM [YOUR_PROJECT_ID:EXPORT_DATASET.activity]
  WHERE
    record_type = 'drive'
    AND email <> ''
    AND drive.primary_event = true
    AND _PARTITIONTIME >= DATE_ADD(YOUR_TIMESTAMP_PARAMETER, -1, "DAY")
    AND _PARTITIONTIME <= DATE_ADD(YOUR_TIMESTAMP_PARAMETER, 2,"DAY")
    AND DATE(STRFTIME_UTC_USEC(time_usec,"%Y-%m-%d")) = DATE(YOUR_TIMESTAMP_PARAMETER)) drive_usage
WHERE
  domain IN ( YOUR_DOMAINS )
GROUP BY 1, 2
