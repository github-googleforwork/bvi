-- required name of view: user_usage_presentations_daily
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
    user_email AS email,
    NTH(2, SPLIT(user_email, '@')) AS domain,
    drive.num_owned_google_presentations_created   AS num_preso_created,
    drive.num_owned_google_presentations_edited AS num_preso_edited,
    drive.num_owned_google_presentations_trashed AS num_preso_trashed,
    drive.num_owned_google_presentations_viewed AS num_preso_viewed
  FROM
    [YOUR_PROJECT_ID:EXPORT_DATASET.usage]
  WHERE
    TRUE
    AND _PARTITIONTIME = YOUR_TIMESTAMP_PARAMETER
    AND (drive.num_owned_google_presentations_created + drive.num_owned_google_presentations_edited + drive.num_owned_google_presentations_trashed + drive.num_owned_google_presentations_viewed) > 0
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