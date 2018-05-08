--active_users_drive_gmail
--review: 2017-10-30

SELECT
  date,
  email,
FROM
  [YOUR_PROJECT_ID:users.active_users_with_ou_per_day_drive_gmail]
WHERE
  DATE(date) = DATE(YOUR_TIMESTAMP_PARAMETER)
GROUP BY 1, 2
