-- required name of view: user_usage_forms_daily
-- Review: 04/09/2019
SELECT
  user_usage.date AS date,
  user_usage.email AS email,
  IFNULL(users.ou, 'NA') AS ou,
  user_usage.num_forms_created + user_usage.num_forms_edited + user_usage.num_forms_trashed + user_usage.num_forms_viewed AS num_forms,
  user_usage.num_forms_created as num_forms_created,
  user_usage.num_forms_edited as num_forms_edited,
  user_usage.num_forms_trashed as num_forms_trashed,
  user_usage.num_forms_viewed as num_forms_viewed 
FROM (
  SELECT
    date,
    user_email AS email,
    NTH(2, SPLIT(user_email, '@')) AS domain,
    drive.num_google_forms_created  AS num_forms_created,
    drive.num_google_forms_edited AS num_forms_edited,
    drive.num_google_forms_trashed AS num_forms_trashed,
    drive.num_google_forms_viewed AS num_forms_viewed
  FROM
    [YOUR_PROJECT_ID:EXPORT_DATASET.usage]
  WHERE TRUE
    AND _PARTITIONTIME = YOUR_TIMESTAMP_PARAMETER
    AND (drive.num_google_forms_created + drive.num_google_forms_edited + drive.num_google_forms_trashed + drive.num_google_forms_viewed) > 0
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