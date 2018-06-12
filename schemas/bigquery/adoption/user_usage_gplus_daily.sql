-- user_usage_gplus_daily (view)
SELECT
  user_usage.date AS date,
  user_usage.email AS email,
  IFNULL(users.ou, 'NA') AS ou,
  user_usage.num_shares AS num_shares,
  user_usage.num_plusones as num_plusones,
  user_usage.num_replies as num_replies,
  user_usage.num_reshares as num_reshares
FROM (
  SELECT
    date,
    entity.userEmail AS email,
    IF(parameters.name = "gplus:num_shares",IFNULL(parameters.intValue,NULL),0) as num_shares,
    IF(parameters.name = "gplus:num_plusones",IFNULL(parameters.intValue,NULL),0) as num_plusones,
    IF(parameters.name = "gplus:num_replies",IFNULL(parameters.intValue,NULL),0) as num_replies,
    IF(parameters.name = "gplus:num_reshares",IFNULL(parameters.intValue,NULL),0) as num_reshares
  FROM
    [YOUR_PROJECT_ID:raw_data.user_usage]
  WHERE
    _PARTITIONTIME = YOUR_TIMESTAMP_PARAMETER
    AND parameters.name IN ('gplus:num_shares', 'gplus:num_plusones', 'gplus:num_replies', 'gplus:num_reshares')
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
GROUP BY 1,2,3,4,5,6,7