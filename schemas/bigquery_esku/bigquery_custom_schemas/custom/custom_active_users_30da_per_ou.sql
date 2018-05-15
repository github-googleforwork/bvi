-- CUSTOM custom_active_users_30da_per_ou
-- Review: 24/01/2018

SELECT
  DATE(DATE_ADD(CURRENT_DATE(),-4,"DAY")) AS date,
  IFNULL(active_users.ou, 'undefined') AS ou,
  IFNULL(custom.custom_1, 'undefined') AS custom_1,
  IFNULL(custom.custom_2, 'undefined') AS custom_2,
  IFNULL(custom.custom_3, 'undefined') AS custom_3,
  EXACT_COUNT_DISTINCT(active_users.email) AS count,
  COUNT(active_users.email) AS sum
FROM
  [YOUR_PROJECT_ID:users.active_users_with_ou_per_day] active_users
LEFT JOIN
  (SELECT email, custom_1, custom_2, custom_3, FROM [YOUR_PROJECT_ID:custom.raw_custom_fields] GROUP BY 1,2,3,4) custom
ON
  active_users.email = custom.email
WHERE
  active_users._PARTITIONTIME > DATE_ADD(CURRENT_DATE(),-34,"DAY")
GROUP BY  2,  3,  4,  5
