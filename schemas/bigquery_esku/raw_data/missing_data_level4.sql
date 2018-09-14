-- missing_data_level4 (view)

SELECT
  run_days.report_date AS report_date,
  gplus.num_1day_active_users AS gplus
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
    num_1day_active_users
  FROM
    [YOUR_PROJECT_ID:adoption.gplus_adoption_daily]) gplus
ON
  gplus.date = run_days.report_date

WHERE
  gplus.num_1day_active_users IS NULL
ORDER BY
  1 DESC