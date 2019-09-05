-- required name of view: user_usage_forms_daily
-- Review: 04/09/2019
SELECT
  user_usage.date AS date,
  user_usage.email AS email,
  IFNULL(users.ou, 'NA') AS ou,
  SUM(user_usage.num_forms_created + user_usage.num_forms_edited + user_usage.num_forms_trashed + user_usage.num_forms_viewed) AS num_forms,
  SUM(user_usage.num_forms_created) as num_forms_created,
  SUM(user_usage.num_forms_edited) as num_forms_edited,
  SUM(user_usage.num_forms_trashed) as num_forms_trashed,
  SUM(user_usage.num_forms_viewed) as num_forms_viewed 
FROM (
  SELECT
    date,
    entity.userEmail AS email,
    NTH(2, SPLIT(entity.userEmail, '@')) AS domain,
    IF(parameters.name = "drive:num_google_forms_created",IFNULL(parameters.intValue,NULL),0) as num_forms_created,
    IF(parameters.name = "drive:num_google_forms_edited",IFNULL(parameters.intValue,NULL),0) as num_forms_edited,
    IF(parameters.name = "drive:num_google_forms_trashed",IFNULL(parameters.intValue,NULL),0) as num_forms_trashed,
    IF(parameters.name = "drive:num_google_forms_viewed",IFNULL(parameters.intValue,NULL),0) as num_forms_viewed
  FROM
    [YOUR_PROJECT_ID:raw_data.user_usage]
  WHERE
    _PARTITIONTIME = YOUR_TIMESTAMP_PARAMETER
    AND parameters.name IN ('drive:num_google_forms_created', 'drive:num_google_forms_edited', 'drive:num_google_forms_trashed', 'drive:num_google_forms_viewed')
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
GROUP BY 1,2,3