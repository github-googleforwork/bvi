-- gplus_30day_summary

SELECT
  DATE(YOUR_TIMESTAMP_PARAMETER) AS date,
  SUM(num_plusones) AS total_num_plusones,
  SUM(num_replies) AS total_num_replies,
  SUM(num_reshares) AS total_num_reshares,
  SUM(num_shares) AS total_num_shares
FROM
  [YOUR_PROJECT_ID:adoption.gplus_adoption_daily]
WHERE
  _PARTITIONTIME >= DATE_ADD(YOUR_TIMESTAMP_PARAMETER, -30, "DAY")
  AND _PARTITIONTIME < DATE_ADD(YOUR_TIMESTAMP_PARAMETER, 1,"DAY")