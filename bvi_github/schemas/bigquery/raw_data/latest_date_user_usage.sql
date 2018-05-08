-- latest_date_user_usage
-- Review: 22/02/2017
SELECT
  date,
  COUNT(*) AS count
FROM
  [YOUR_PROJECT_ID:raw_data.user_usage]
GROUP BY 1
ORDER BY 1 DESC