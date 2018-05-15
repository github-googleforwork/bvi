--total_active_users_30day
--review: 2017-11-22

SELECT
  DATE(YOUR_TIMESTAMP_PARAMETER) AS date,
  EXACT_COUNT_DISTINCT(email) AS count
FROM
  [YOUR_PROJECT_ID:users.drive_users_30day],
  [YOUR_PROJECT_ID:users.gmail_users_30day]
WHERE
  _PARTITIONTIME = YOUR_TIMESTAMP_PARAMETER
  