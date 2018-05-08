
-- active_users_with_ou_per_day_drive_gmail
-- Review: 2017-11-05


SELECT
  active_users.date AS date,
  active_users.email AS email,
  IFNULL(users.ou, 'NA') AS ou
FROM (
  SELECT
    date,
    email
  FROM
    [YOUR_PROJECT_ID:users.audit_log_active_users_per_day_drive_gmail]
  WHERE
    _PARTITIONTIME = TIMESTAMP(YOUR_TIMESTAMP_PARAMETER)) active_users
LEFT JOIN
  [YOUR_PROJECT_ID:users.users_ou_list] users
ON
  active_users.email = users.email
WHERE
_PARTITIONTIME = TIMESTAMP(YOUR_TIMESTAMP_PARAMETER)
GROUP BY 1, 2, 3