-- latest_date_audit_log (view)
-- Review: 23/10/2017
SELECT
  date_prof AS date,
  pt,
  COUNT(*) AS count
FROM (
  SELECT
	date as date_prof,
    _PARTITIONTIME as pt,
	*
  FROM [YOUR_PROJECT_ID:raw_data.audit_log_profilable_events]
)
GROUP BY
  1, 2
ORDER BY
  1 DESC, 2 DESC