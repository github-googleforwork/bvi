-- required name of view: user_usage_non_native_files_daily
-- Review: 04/09/2019
SELECT
  user_usage.date AS date,
  user_usage.email AS email,
  IFNULL(users.ou, 'NA') AS ou,
  user_usage.num_non_native_files_created + user_usage.num_non_native_files_edited + user_usage.num_non_native_files_trashed + user_usage.num_non_native_files_viewed AS num_non_native_files,
  user_usage.num_non_native_files_created as num_non_native_files_created,
  user_usage.num_non_native_files_edited as num_non_native_files_edited,
  user_usage.num_non_native_files_trashed as num_non_native_files_trashed,
  user_usage.num_non_native_files_viewed as num_non_native_files_viewed
FROM (
  SELECT
    date,
    user_email AS email,
    NTH(2, SPLIT(user_email, '@')) AS domain,
    drive.num_other_types_created  AS num_non_native_files_created,
    drive.num_other_types_edited AS num_non_native_files_edited,
    drive.num_other_types_trashed AS num_non_native_files_trashed,
    drive.num_other_types_viewed AS num_non_native_files_viewed
  FROM
    [YOUR_PROJECT_ID:EXPORT_DATASET.usage]
  WHERE
    TRUE
    AND _PARTITIONTIME = YOUR_TIMESTAMP_PARAMETER
    AND (drive.num_other_types_created + drive.num_other_types_edited + drive.num_other_types_trashed + drive.num_other_types_viewed) > 0
    AND record_type = 'user' ) user_usage
LEFT JOIN (
  SELECT
    ou,
    email
  FROM
    [YOUR_PROJECT_ID:users.users_ou_list]
  WHERE
    TRUE
    AND _PARTITIONTIME = YOUR_TIMESTAMP_PARAMETER) users
ON
  users.email = user_usage.email
WHERE
  domain IN ( YOUR_DOMAINS )