-- active_users_with_ou_per_day
-- Review: 16/06/2017
SELECT
  data.date AS date,
  data.email AS email,
  IFNULL(users.ou, 'NA') AS ou
FROM (
  SELECT
    DATE(YOUR_TIMESTAMP_PARAMETER) AS date,
    email
  FROM
    [YOUR_PROJECT_ID:users.audit_log_active_users_per_day]
  WHERE
    _PARTITIONTIME = YOUR_TIMESTAMP_PARAMETER) data
LEFT JOIN
  [YOUR_PROJECT_ID:users.users_ou_list] users
ON
  users.email = data.email
WHERE
  _PARTITIONTIME = YOUR_TIMESTAMP_PARAMETER
GROUP BY 1, 2, 3