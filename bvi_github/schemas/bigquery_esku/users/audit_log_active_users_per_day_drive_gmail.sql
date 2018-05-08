--audit_log_active_users_per_day_drive_gmail
--review: 2017-10-30

SELECT
  date, 
  email,
  count(*) as count
FROM
  [YOUR_PROJECT_ID:users.drive_users_1day],
  [YOUR_PROJECT_ID:users.gmail_users_1day] 
WHERE
  DATE(_PARTITIONTIME) = DATE(YOUR_TIMESTAMP_PARAMETER)
GROUP BY 1,2
