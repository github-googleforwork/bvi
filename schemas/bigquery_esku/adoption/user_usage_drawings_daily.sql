-- user_usage_drawings_daily
SELECT
  user_usage.date AS date,
  user_usage.email AS email,
  IFNULL(users.ou, 'NA') AS ou,
  user_usage.num_draws_created AS num_drawings,
  user_usage.num_draws_created as num_draws_created,
  user_usage.num_draws_edited as num_draws_edited,
  user_usage.num_draws_trashed as num_draws_trashed,
  user_usage.num_draws_viewed as num_draws_viewed 
FROM (
  SELECT
    date,
    user_email AS email,
    NTH(2, SPLIT(user_email, '@')) AS domain,
    drive.num_owned_google_drawings_created  AS num_draws_created,
    drive.num_owned_google_drawings_edited AS num_draws_edited,
    drive.num_owned_google_drawings_trashed AS num_draws_trashed,
    drive.num_owned_google_drawings_viewed AS num_draws_viewed
  FROM
    [YOUR_PROJECT_ID:Reports.usage]
  WHERE TRUE
    AND _PARTITIONTIME = YOUR_TIMESTAMP_PARAMETER
    AND (drive.num_owned_google_drawings_created + drive.num_owned_google_drawings_edited + drive.num_owned_google_drawings_trashed + drive.num_owned_google_drawings_viewed) > 0
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
GROUP BY 1,2,3,4,5,6,7,8