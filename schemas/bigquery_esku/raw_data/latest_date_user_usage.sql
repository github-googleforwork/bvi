-- latest_date_user_usage
SELECT
  usage.date AS date,
  COUNT(*) AS count
FROM
  [YOUR_PROJECT_ID:Reports.usage] usage
WHERE
  usage.record_type = 'user'
GROUP BY 1
ORDER BY 1 DESC