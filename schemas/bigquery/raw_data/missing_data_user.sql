-- missing_data_user (view)
SELECT
  run_days.report_date AS report_date,
  gen_data.drive AS drive,
  gen_data.gmail AS gmail,
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
        WHEN parameters.name = 'drive:num_items_viewed' THEN (IFNULL(parameters.intValue,NULL))
        ELSE NULL END) AS drive,
    MAX(CASE
        WHEN parameters.name = 'gmail:last_interaction_time' THEN (IFNULL(parameters.datetimeValue,NULL))
        ELSE NULL END) AS gmail,
    SUM(CASE
        WHEN parameters.name = 'gplus:num_shares' THEN (IFNULL(parameters.intValue,NULL))
        ELSE NULL END) AS gplus
  FROM
    [YOUR_PROJECT_ID:raw_data.user_usage]
  GROUP BY
    1) gen_data
ON
  gen_data.date = run_days.report_date
WHERE
  gen_data.drive IS NULL
  OR gen_data.gmail IS NULL
  OR gen_data.gplus IS NULL
ORDER BY
  1 DESC