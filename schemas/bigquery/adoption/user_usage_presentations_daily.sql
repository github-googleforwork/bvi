-- required name of view: user_usage_presentations_daily
-- Review: 16/03/2017
SELECT
  user_usage.date AS date,
  user_usage.email AS email,
  IFNULL(users.ou, 'NA') AS ou,
  user_usage.num_preso_created AS num_presentations,
  user_usage.num_preso_created as num_preso_created,
  user_usage.num_preso_edited as num_preso_edited,
  user_usage.num_preso_trashed as num_preso_trashed,
  user_usage.num_preso_viewed as num_preso_viewed 
FROM (
  SELECT
    date,
    entity.userEmail AS email,
    NTH(2, SPLIT(entity.userEmail, '@')) AS domain,
    IF(parameters.name = "drive:num_owned_google_presentations_created",IFNULL(parameters.intValue,NULL),0) as num_preso_created,
    IF(parameters.name = "drive:num_owned_google_presentations_edited",IFNULL(parameters.intValue,NULL),0) as num_preso_edited,
    IF(parameters.name = "drive:num_owned_google_presentations_trashed",IFNULL(parameters.intValue,NULL),0) as num_preso_trashed,
    IF(parameters.name = "drive:num_owned_google_presentations_viewed",IFNULL(parameters.intValue,NULL),0) as num_preso_viewed
  FROM
    [YOUR_PROJECT_ID:raw_data.user_usage]
  WHERE
    _PARTITIONTIME = YOUR_TIMESTAMP_PARAMETER
    AND parameters.name IN ('drive:num_owned_google_presentations_created', 'drive:num_owned_google_presentations_edited', 'drive:num_owned_google_presentations_trashed', 'drive:num_owned_google_presentations_viewed' )
    AND parameters.intValue > 0 )user_usage
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
GROUP BY 1,2,3,4,5,6,7,8