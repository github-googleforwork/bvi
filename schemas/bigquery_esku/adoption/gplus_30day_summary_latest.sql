-- gplus_30day_summary_latest (view)
SELECT
  date,
  total_num_plusones,
  total_num_replies,
  total_num_reshares,
  total_num_shares
FROM
  [YOUR_PROJECT_ID:adoption.gplus_30day_summary],
WHERE
  date = (SELECT MAX(date) FROM [YOUR_PROJECT_ID:adoption.adoption_30day])