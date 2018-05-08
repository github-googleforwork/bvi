-- latest_date_customer_usage
SELECT
  usage.date AS date,
  COUNT(*) AS count
FROM
  [YOUR_PROJECT_ID:Reports.usage] usage
WHERE
  usage.record_type = 'customer'
GROUP BY 1
ORDER BY 1 DESC