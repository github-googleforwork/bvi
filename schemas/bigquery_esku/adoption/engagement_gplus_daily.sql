-- engagement_gplus_daily

SELECT
  adoption.date AS date,
  adoption.num_30day_active_users AS num_30day_active_users,
  SUM(IF(engagement.num_shares>0,1,0)) AS num_share_users,
  SUM(IF(engagement.num_plusones>0,1,0)) AS num_plusone_users,
  SUM(IF(engagement.num_replies>0,1,0)) AS num_reply_users,
  SUM(IF(engagement.num_reshares>0,1,0)) AS num_reshare_users
FROM
  [YOUR_PROJECT_ID:adoption.gplus_adoption_daily] adoption
LEFT JOIN
  [YOUR_PROJECT_ID:adoption.user_usage_gplus_daily] engagement
ON
  adoption.date = engagement.date
WHERE
  adoption.date = DATE(YOUR_TIMESTAMP_PARAMETER)
GROUP BY
  1,
  2