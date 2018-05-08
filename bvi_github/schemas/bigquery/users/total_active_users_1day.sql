--total_active_users_1day
--review: 2017-12-04

SELECT
  DATE(YOUR_TIMESTAMP_PARAMETER) AS date,
  EXACT_COUNT_DISTINCT(email) AS count
FROM
  [YOUR_PROJECT_ID:users.drive_users_1day],
  [YOUR_PROJECT_ID:users.gmail_users_1day]
WHERE
  _PARTITIONTIME = TIMESTAMP(YOUR_TIMESTAMP_PARAMETER)
  