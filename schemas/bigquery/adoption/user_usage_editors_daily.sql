-- required name of view: user_usage_editors_daily
-- Review: 15/02/2017
SELECT
  user_usage.date AS date,
  user_usage.email AS email,
  IFNULL(users.ou, 'NA') AS ou,
  SUM(user_usage.num_docs_edited) AS num_docs_edited
FROM (
  SELECT
    date,
    entity.userEmail AS email,
    parameters.intValue AS num_docs_edited
  FROM
    [YOUR_PROJECT_ID:raw_data.user_usage]
  WHERE
    _PARTITIONTIME = YOUR_TIMESTAMP_PARAMETER
    AND parameters.name IN ('drive:num_owned_items_created', 'drive:num_owned_items_edited', 'drive:num_owned_items_trashed')
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
GROUP BY 1,2,3
