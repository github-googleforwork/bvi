-- latest_date_users_list_date (view)
-- Review: 22/02/2017
SELECT
  date,
  COUNT(*) AS count
FROM
  [YOUR_PROJECT_ID:raw_data.users_list_date]
GROUP BY 1
ORDER BY 1 DESC