-- active_users
-- Review: 14/02/2017
SELECT
  date,
  email,
FROM
  [YOUR_PROJECT_ID:users.active_users_with_ou_per_day]
WHERE
  DATE(date) = DATE(YOUR_TIMESTAMP_PARAMETER)
GROUP BY 1, 2