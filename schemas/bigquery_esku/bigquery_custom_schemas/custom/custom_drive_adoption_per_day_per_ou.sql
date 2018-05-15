-- CUSTOM custom_drive_adoption_per_day_per_ou
-- Review: 19/01/2018

SELECT
  audit_log_drive_adoption.date AS date,
  audit_log_drive_adoption.ou AS ou,
  audit_log_drive_adoption.custom_1 AS custom_1,
  audit_log_drive_adoption.custom_2 AS custom_2,
  audit_log_drive_adoption.custom_3 AS custom_3,
  active_users.count AS active_users,
  audit_log_drive_adoption.count AS users_adopted_drive,
  ( audit_log_drive_adoption.count / active_users.count ) AS drive_adoption,
  ROUND( audit_log_drive_adoption.count / active_users.count, 2) AS drive_adoption_hr,
FROM (
  SELECT
    data.date AS date,
    IFNULL(active_users.ou, 'undefined') AS ou,
    IFNULL(custom.custom_1, 'undefined') AS custom_1,
    IFNULL(custom.custom_2, 'undefined') AS custom_2,
    IFNULL(custom.custom_3, 'undefined') AS custom_3,
    EXACT_COUNT_DISTINCT(data.email) AS count
  FROM
    [YOUR_PROJECT_ID:adoption.audit_log_drive_adoption_per_day] data
  INNER JOIN
    [YOUR_PROJECT_ID:users.active_users_with_ou_per_day] active_users
  ON
    active_users.email = data.email
    AND active_users.date = data.date
  LEFT JOIN
    [YOUR_PROJECT_ID:custom.raw_custom_fields] custom
  ON
    active_users.email = custom.email    
  WHERE
    TRUE
    AND data._PARTITIONTIME = YOUR_TIMESTAMP_PARAMETER
    AND active_users._PARTITIONTIME = YOUR_TIMESTAMP_PARAMETER
  GROUP BY 1, 2, 3, 4, 5) audit_log_drive_adoption
INNER JOIN (
  SELECT
    date,
    ou,
    IFNULL(custom_1, 'undefined') AS custom_1,
    IFNULL(custom_2, 'undefined') AS custom_2,
    IFNULL(custom_3, 'undefined') AS custom_3,
    COUNT(active_users_per_day.email) AS count
  FROM
    [YOUR_PROJECT_ID:users.active_users_with_ou_per_day] active_users_per_day
  LEFT JOIN
    (SELECT email, custom_1, custom_2, custom_3, FROM [YOUR_PROJECT_ID:custom.raw_custom_fields] GROUP BY 1,2,3,4) custom
  ON
    active_users_per_day.email = custom.email
  WHERE
    TRUE
    AND active_users_per_day._PARTITIONTIME = YOUR_TIMESTAMP_PARAMETER
  GROUP BY 1, 2, 3, 4, 5 ) active_users
ON
  audit_log_drive_adoption.ou = active_users.ou
  AND audit_log_drive_adoption.custom_1 = active_users.custom_1
  AND audit_log_drive_adoption.custom_2 = active_users.custom_2
  AND audit_log_drive_adoption.custom_3 = active_users.custom_3
  AND audit_log_drive_adoption.date = active_users.date
