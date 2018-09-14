-- missing_data_level6 (view)
SELECT
  run_days.report_date AS report_date,
  calendar.calendar_adoption AS calendar
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
    calendar_adoption
  FROM
    [YOUR_PROJECT_ID:adoption.adoption]) calendar
ON
  calendar.date = run_days.report_date

WHERE
  calendar.calendar_adoption IS NULL
ORDER BY
  1 DESC