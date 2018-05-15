-- drive_adoption_per_day_per_ou
-- Review: 23/02/2017
SELECT
  audit_log_drive_adoption.date AS date,
  audit_log_drive_adoption.ou AS ou,
  active_users.count AS active_users,
  audit_log_drive_adoption.count AS users_adopted_drive,
  ( audit_log_drive_adoption.count / active_users.count ) AS drive_adoption,
  ROUND( audit_log_drive_adoption.count / active_users.count, 2) AS drive_adoption_hr,
FROM (
  SELECT
    data.date AS date,
    IFNULL(active_users.ou, 'NA') AS ou,
    EXACT_COUNT_DISTINCT(data.email) AS count
  FROM
    [YOUR_PROJECT_ID:adoption.audit_log_drive_adoption_per_day] data
  INNER JOIN
    [YOUR_PROJECT_ID:users.active_users_with_ou_per_day] active_users
  ON
    active_users.email = data.email
    AND active_users.date = data.date
  WHERE
    TRUE
    AND data._PARTITIONTIME = YOUR_TIMESTAMP_PARAMETER
    AND active_users._PARTITIONTIME = YOUR_TIMESTAMP_PARAMETER
  GROUP BY 1, 2) audit_log_drive_adoption
INNER JOIN (
  SELECT
    date,
    ou,
    COUNT(email) AS count
  FROM
    [YOUR_PROJECT_ID:users.active_users_with_ou_per_day]
  WHERE
    TRUE
    AND _PARTITIONTIME = YOUR_TIMESTAMP_PARAMETER
  GROUP BY 1, 2 ) active_users
ON
  audit_log_drive_adoption.ou = active_users.ou
  AND audit_log_drive_adoption.date = active_users.date