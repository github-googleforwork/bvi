-- user_usage_drawings_daily
-- Review: 04/09/2019
SELECT
  user_usage.date AS date,
  user_usage.email AS email,
  IFNULL(users.ou, 'NA') AS ou,
  SUM(user_usage.num_draws_created + user_usage.num_draws_edited + user_usage.num_draws_trashed + user_usage.num_draws_viewed) AS num_drawings,
  SUM(user_usage.num_draws_created) as num_draws_created,
  SUM(user_usage.num_draws_edited) as num_draws_edited,
  SUM(user_usage.num_draws_trashed) as num_draws_trashed,
  SUM(user_usage.num_draws_viewed) as num_draws_viewed
FROM (
  SELECT
    date,
    entity.userEmail AS email,
    NTH(2, SPLIT(entity.userEmail, '@')) AS domain,
    IF(parameters.name = "drive:num_google_drawings_created",IFNULL(parameters.intValue,NULL),0) as num_draws_created,
    IF(parameters.name = "drive:num_google_drawings_edited",IFNULL(parameters.intValue,NULL),0) as num_draws_edited,
    IF(parameters.name = "drive:num_google_drawings_trashed",IFNULL(parameters.intValue,NULL),0) as num_draws_trashed,
    IF(parameters.name = "drive:num_google_drawings_viewed",IFNULL(parameters.intValue,NULL),0) as num_draws_viewed
  FROM
    [YOUR_PROJECT_ID:raw_data.user_usage]
  WHERE
    _PARTITIONTIME = YOUR_TIMESTAMP_PARAMETER
    AND parameters.name IN ('drive:num_google_drawings_created', 'drive:num_google_drawings_edited', 'drive:num_google_drawings_trashed', 'drive:num_google_drawings_viewed')
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