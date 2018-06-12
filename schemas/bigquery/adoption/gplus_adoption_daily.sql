-- gplus_adoption_daily

SELECT
  usage.date AS date,
  SUM(CASE WHEN parameters.name = 'gplus:num_1day_active_users' THEN (IFNULL(parameters.intValue,NULL)) ELSE 0 END) AS num_1day_active_users,
  SUM(CASE WHEN parameters.name = 'gplus:num_7day_active_users' THEN (IFNULL(parameters.intValue,NULL)) ELSE 0 END) AS num_7day_active_users,
  SUM(CASE WHEN parameters.name = 'gplus:num_30day_active_users' THEN (IFNULL(parameters.intValue,NULL)) ELSE 0 END) AS num_30day_active_users,
  MAX(total_active_users.count) AS num_total_active_users,
  SUM(CASE WHEN parameters.name = 'gplus:num_communities' THEN (IFNULL(parameters.intValue,NULL)) ELSE 0 END) AS num_communities,
  SUM(CASE WHEN parameters.name = 'gplus:num_plusones' THEN (IFNULL(parameters.intValue,NULL)) ELSE 0 END) AS num_plusones,
  SUM(CASE WHEN parameters.name = 'gplus:num_replies' THEN (IFNULL(parameters.intValue,NULL)) ELSE 0 END) AS num_replies,
  SUM(CASE WHEN parameters.name = 'gplus:num_reshares' THEN (IFNULL(parameters.intValue,NULL)) ELSE 0 END) AS num_reshares,
  SUM(CASE WHEN parameters.name = 'gplus:num_shares' THEN (IFNULL(parameters.intValue,NULL)) ELSE 0 END) AS num_shares
FROM
  [YOUR_PROJECT_ID:users.total_active_users_30day] total_active_users
LEFT JOIN [YOUR_PROJECT_ID:raw_data.customer_usage] usage
  ON usage.date = total_active_users.date
WHERE usage._PARTITIONTIME = YOUR_TIMESTAMP_PARAMETER
GROUP BY 1