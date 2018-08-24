-- latest_date_customer_usage (view)
SELECT
  usage.date AS date,
  COUNT(*) AS count
FROM
  [YOUR_PROJECT_ID:EXPORT_DATASET.usage] usage
WHERE
  usage.record_type = 'customer'
GROUP BY 1
ORDER BY 1 DESC