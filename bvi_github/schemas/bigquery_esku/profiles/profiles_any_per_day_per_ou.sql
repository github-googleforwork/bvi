-- profiles_any_per_day_per_ou
-- Review: 24/08/2017
SELECT
  data.date AS date,
  data.email AS email,
  IFNULL( active_users.ou, 'NA' ) AS ou,
  is_creator,
  is_collaborator,
  is_consumer,
  is_sharer
FROM
  [YOUR_PROJECT_ID:profiles.profiles_any_per_day_no_ou] data
JOIN
  [YOUR_PROJECT_ID:users.active_users_with_ou_per_day] active_users
ON
  active_users.email = data.email
WHERE
  TRUE
  AND data._PARTITIONTIME = YOUR_TIMESTAMP_PARAMETER
  AND active_users._PARTITIONTIME = YOUR_TIMESTAMP_PARAMETER
GROUP BY
  1, 2, 3, 4, 5, 6, 7