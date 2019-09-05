-- required name of view: user_usage_readers_daily
-- Review: 04/09/2019
SELECT
  user_usage.date AS date,
  user_usage.email AS email,
  IFNULL(users.ou, 'NA') AS ou,
  drive.num_items_viewed AS num_docs_viewed
FROM (
  SELECT
    date,
    user_email AS email,
    NTH(2, SPLIT(user_email, '@')) AS domain,
    drive.num_items_viewed
  FROM
    [YOUR_PROJECT_ID:EXPORT_DATASET.usage]
  WHERE
    TRUE
    AND _PARTITIONTIME = YOUR_TIMESTAMP_PARAMETER
    AND drive.num_items_viewed > 0
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