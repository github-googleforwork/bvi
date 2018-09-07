-- profiles_any_last_N_days (view)
-- Review: 24/08/2017
SELECT
  DATE(DATE_ADD(CURRENT_DATE(),-4,"DAY")) AS date,
  email,
  ou,
  SUM(is_creator) AS is_creator,
  SUM(is_collaborator) AS is_collaborator,
  SUM(is_consumer) AS is_consumer,
  SUM(is_sharer) AS is_sharer,
FROM [YOUR_PROJECT_ID:profiles.profiles_any_per_day_per_ou]
WHERE
  TRUE
  AND _PARTITIONTIME >= DATE_ADD((SELECT MAX(date) FROM [YOUR_PROJECT_ID:adoption.adoption_30day]),-30,"DAY")
GROUP BY 2, 3
ORDER BY 2