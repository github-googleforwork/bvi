-- missing_data_level1 (view)

SELECT
  run_days.report_date AS report_date,
  meet.average_meeting_minutes AS meet,
  drive.drive_adoption AS drive,
  gmail.count AS gmail
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
    average_meeting_minutes
  FROM
    [YOUR_PROJECT_ID:adoption.meetings_adoption_daily]) meet
ON
  meet.date = run_days.report_date
LEFT JOIN (
  SELECT
    date,
    drive_adoption
  FROM
    [YOUR_PROJECT_ID:users.drive_active_users_30day]) drive
ON
  drive.date = run_days.report_date
LEFT JOIN (
  SELECT
    date,
    count
  FROM
    [YOUR_PROJECT_ID:users.gmail_active_users_30day]) gmail
ON
  gmail.date = run_days.report_date
WHERE
  meet.average_meeting_minutes IS NULL
  OR drive.drive_adoption IS NULL
  OR gmail.count IS NULL
ORDER BY
  1 DESC