-- gplus_adoption_daily_latest (view)
SELECT
  date,
  num_1day_active_users,
  num_7day_active_users,
  num_30day_active_users,
  num_total_active_users,
  num_communities,
  num_plusones,
  num_replies,
  num_reshares,
  num_shares
FROM
  [YOUR_PROJECT_ID:adoption.gplus_adoption_daily],
WHERE
  date = DATE(DATE_ADD(TIMESTAMP(CURRENT_DATE()), -4, "DAY"))