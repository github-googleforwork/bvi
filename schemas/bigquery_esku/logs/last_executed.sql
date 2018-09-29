-- last_executed (view)

SELECT
  report_date,
  MAX(start_time) AS last_executed
FROM
  [YOUR_PROJECT_ID:logs.bvi_logs]
WHERE
  message = "Start of first step"
  AND message_id = "start"
GROUP BY
  report_date