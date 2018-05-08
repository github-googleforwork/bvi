-- active_users_30da_per_ou
-- Review: 16/06/2017  
SELECT
  DATE(YOUR_TIMESTAMP_PARAMETER) as date,
  ou,
  EXACT_COUNT_DISTINCT(email) as count,
  COUNT(email) as sum
FROM
  [YOUR_PROJECT_ID:users.active_users_with_ou_per_day]
WHERE
  _PARTITIONTIME > DATE_ADD(YOUR_TIMESTAMP_PARAMETER,-30,"DAY")
GROUP BY 2