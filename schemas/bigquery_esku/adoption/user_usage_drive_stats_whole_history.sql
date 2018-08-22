-- user_usage_drive_stats_whole_history
SELECT
  user_usage.date AS date,
  user_usage.email AS email,
  IFNULL(users.ou, 'NA') AS ou,
  SUM(drive.num_items_edited + drive.num_owned_items_edited) AS num_docs_edited,
  SUM(drive.num_items_viewed + drive.num_owned_items_viewed) AS num_docs_viewed
FROM (
  SELECT
    date,
    user_email AS email,
    NTH(2, SPLIT(user_email, '@')) AS domain,
    drive.num_items_viewed,
    drive.num_owned_items_viewed,
    drive.num_items_edited,
    drive.num_owned_items_edited
  FROM
    [YOUR_PROJECT_ID:Reports.usage]
  WHERE
    TRUE
    AND _PARTITIONTIME = YOUR_TIMESTAMP_PARAMETER
    AND (drive.num_items_viewed + drive.num_owned_items_viewed + drive.num_items_edited + drive.num_owned_items_edited) > 0
    AND record_type = 'user' ) user_usage
LEFT JOIN (
  SELECT
    ou,
    email
  FROM
    [YOUR_PROJECT_ID:users.users_ou_list]
  WHERE
    TRUE
    AND _PARTITIONTIME = YOUR_TIMESTAMP_PARAMETER ) users
ON
  users.email = user_usage.email
WHERE
  domain IN ( YOUR_DOMAINS )
GROUP BY 1,2,3