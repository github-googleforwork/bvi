-- gplus_adoption_daily

SELECT
  usage.date AS date,
  SUM(gplus.num_1day_active_users) AS num_1day_active_users,
  SUM(gplus.num_7day_active_users) AS num_7day_active_users,
  SUM(gplus.num_30day_active_users) AS num_30day_active_users,
  MAX(total_active_users.count) AS num_total_active_users,
  SUM(gplus.num_communities) AS num_communities,
  SUM(gplus.num_plusones) AS num_plusones,
  SUM(gplus.num_replies) AS num_replies,
  SUM(gplus.num_reshares) AS num_reshares,
  SUM(gplus.num_shares) AS num_shares
FROM
  [YOUR_PROJECT_ID:users.total_active_users_30day] total_active_users
LEFT JOIN [YOUR_PROJECT_ID:Reports.usage] usage
  ON usage.date = total_active_users.date
WHERE usage._PARTITIONTIME = YOUR_TIMESTAMP_PARAMETER
GROUP BY 1