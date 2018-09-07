-- collaboration_adoption_latest_30d (view)
-- Review: 27/02/2017
SELECT 
  adoption.ou AS ou,
  adoption.active_users_total AS adoption_users,
  users.count AS active_users,
  drive.active_users as drive_users,
  (adoption.P_docs_adoption) AS P_docs_adoption,
  (drive.P_drive_adoption) AS P_drive_adoption,
  ROUND((adoption.P_docs_adoption + drive.P_drive_adoption)/2, 2) AS P_collaboration_adoption
FROM (
  SELECT
    ou,
    SUM(active_users_total) AS active_users_total,
    SUM(document) AS users_adopted_docs,
    (SUM(document)/SUM(active_users_total)) AS P_docs_adoption
  FROM
    [YOUR_PROJECT_ID:adoption.product_adoption_daily]
  WHERE
    _PARTITIONTIME >= DATE_ADD((SELECT MAX(date) FROM [YOUR_PROJECT_ID:adoption.adoption_30day]),-30,"DAY")
    AND (document) > 0
  GROUP BY 1) adoption
INNER JOIN (
  SELECT
    ou,
    SUM(users_adopted_drive) AS users_adopted_drive,
    SUM(active_users) AS active_users,
    (SUM(users_adopted_drive)/SUM(active_users)) AS P_drive_adoption
  FROM
    [YOUR_PROJECT_ID:adoption.drive_adoption_per_day_per_ou]
  WHERE
    _PARTITIONTIME >= DATE_ADD((SELECT MAX(date) FROM [YOUR_PROJECT_ID:adoption.adoption_30day]),-30,"DAY")
  GROUP BY 1) drive
ON
  adoption.ou = drive.ou
INNER JOIN (
  SELECT
    ou,
    COUNT((email)) AS count
  FROM
    [YOUR_PROJECT_ID:users.active_users_with_ou_per_day]
  WHERE
    _PARTITIONTIME >= DATE_ADD((SELECT MAX(date) FROM [YOUR_PROJECT_ID:adoption.adoption_30day]),-30,"DAY")
  GROUP BY
    1 ) users
ON
  adoption.ou = users.ou
GROUP BY 1, 2, 3, 4, 5, 6, 7
