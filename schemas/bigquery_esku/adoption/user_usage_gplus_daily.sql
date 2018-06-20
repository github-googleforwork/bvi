-- user_usage_gplus_daily
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
    user_email AS email,
    gplus.num_shares as num_shares,
    gplus.num_plusones as num_plusones,
    gplus.num_replies as num_replies,
    gplus.num_reshares as num_reshares
  FROM
    [YOUR_PROJECT_ID:Reports.usage]
  WHERE
    _PARTITIONTIME = YOUR_TIMESTAMP_PARAMETER
    AND (gplus.num_shares + gplus.num_plusones + gplus.num_replies + gplus.num_reshares) > 0
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
GROUP BY 1,2,3,4,5,6,7