-- user_usage_drive_stats_whole_history
-- Review: 16/03/2017
SELECT
  user_usage.date AS date,
  user_usage.email AS email,
  IFNULL(users.ou, 'NA') AS ou,
  IFNULL(SUM(user_usage.num_docs_edited), NULL) AS num_docs_edited,
  IFNULL(SUM(user_usage.num_docs_viewed), NULL) AS num_docs_viewed
FROM (
  SELECT
    date,
    entity.userEmail AS email,
    FIRST(IF(parameters.name IN ("drive:num_items_viewed", "drive:num_owned_items_viewed"),IFNULL(parameters.intValue,NULL),0)) WITHIN RECORD num_docs_viewed,
    FIRST(IF(parameters.name IN ("drive:num_items_edited", "drive:num_owned_items_edited"),IFNULL(parameters.intValue,NULL),0)) WITHIN RECORD num_docs_edited
  FROM (
    SELECT
      date,
      entity.userEmail,
      NTH(2, SPLIT(entity.userEmail, '@')) AS domain,
      parameters.name,
      parameters.intValue
    FROM
      [YOUR_PROJECT_ID:raw_data.user_usage]
    WHERE
      _PARTITIONTIME = YOUR_TIMESTAMP_PARAMETER
      AND parameters.name IN ("drive:num_items_edited", "drive:num_owned_items_edited", "drive:num_items_viewed", "drive:num_owned_items_viewed" )
      AND parameters.intValue > 0 ) inner_user_usage
      WHERE
        domain IN ( YOUR_DOMAINS )
  ) user_usage
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
GROUP BY 1,2,3