-- latest_date_customer_usage
-- Review: 22/02/2017
SELECT
  date,
  COUNT(*) AS count
FROM
  [YOUR_PROJECT_ID:raw_data.customer_usage]
GROUP BY 1
ORDER BY 1 DESC