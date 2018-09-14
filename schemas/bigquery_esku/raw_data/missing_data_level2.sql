-- missing_data_level2 (view)

SELECT
  run_days.report_date AS report_date,
  drive.count AS drive,
  gplus.count AS gplus
FROM (
  SELECT
    report_date
  FROM
    [YOUR_PROJECT_ID:raw_data.daily_report_status]
  GROUP BY
    1 ) run_days
LEFT JOIN (
  SELECT
    date,
    count(*) AS count
  FROM
    [YOUR_PROJECT_ID:adoption.user_usage_drive_stats_whole_history]
  GROUP BY 1) drive
ON
  drive.date = run_days.report_date
LEFT JOIN (
  SELECT
    date,
    count(*) AS count
  FROM
    [YOUR_PROJECT_ID:adoption.user_usage_gplus_daily]
  GROUP BY 1) gplus
ON
  gplus.date = run_days.report_date
WHERE
  drive.count IS NULL
  OR gplus.count IS NULL
ORDER BY
  1 DESC