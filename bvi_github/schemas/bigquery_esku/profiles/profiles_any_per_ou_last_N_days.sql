-- profiles_any_per_ou_last_N_days
-- Review: 24/08/2017
SELECT
  DATE(YOUR_TIMESTAMP_PARAMETER) as date,
  data.email AS email,
  IFNULL( active_users.ou, 'NA' ) AS ou,
  SUM(is_creator) as is_creator,
  SUM(is_collaborator) as is_collaborator,
  SUM(is_consumer) AS is_consumer,  
  SUM(is_sharer) as is_sharer
FROM
  [YOUR_PROJECT_ID:profiles.profiles_any_per_day_no_ou] data
INNER JOIN
  [YOUR_PROJECT_ID:users.active_users_with_ou_per_day] active_users
ON
  active_users.email = data.email
WHERE
  TRUE
  AND active_users._PARTITIONTIME <= YOUR_TIMESTAMP_PARAMETER
  AND active_users._PARTITIONTIME > DATE_ADD(DATE(YOUR_TIMESTAMP_PARAMETER),-34,"DAY")
  AND (is_creator + is_collaborator + is_consumer + is_sharer) > 0
GROUP BY 1, 2, 3