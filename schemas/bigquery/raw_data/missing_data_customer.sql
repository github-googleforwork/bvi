-- missing_data_customer (view)
SELECT
  run_days.report_date AS report_date,
  gen_data.meet AS meet,
  gen_data.drive AS drive,
  gen_data.gmail AS gmail,
  gen_data.calendar AS calendar,
  gen_data.gplus AS gplus,
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
    SUM(CASE
        WHEN parameters.name = 'meet:average_meeting_minutes' THEN (IFNULL(parameters.intValue,NULL))
        ELSE NULL END) AS meet,
    SUM(CASE
        WHEN parameters.name = 'drive:num_30day_active_users' THEN (IFNULL(parameters.intValue,NULL))
        ELSE NULL END) AS drive,
    SUM(CASE
        WHEN parameters.name = 'gmail:num_30day_active_users' THEN (IFNULL(parameters.intValue,NULL))
        ELSE NULL END) AS gmail,
    SUM(CASE
        WHEN parameters.name = 'calendar:num_30day_active_users' THEN (IFNULL(parameters.intValue,NULL))
        ELSE NULL END) AS calendar,
    SUM(CASE
        WHEN parameters.name = 'gplus:num_30day_active_users' THEN (IFNULL(parameters.intValue,NULL))
        ELSE NULL END) AS gplus
  FROM
    [YOUR_PROJECT_ID:raw_data.customer_usage]
  GROUP BY
    1) gen_data
ON
  gen_data.date = run_days.report_date
WHERE
  gen_data.meet IS NULL
  OR gen_data.drive IS NULL
  OR gen_data.gmail IS NULL
  OR gen_data.calendar IS NULL
  OR gen_data.gplus IS NULL
ORDER BY
  1 DESC