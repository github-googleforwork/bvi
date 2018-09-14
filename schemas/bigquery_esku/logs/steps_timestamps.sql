-- steps_timestamps (view)
SELECT
  side1.start_time AS start_time_exec,
  side1.next_time AS next_time_exec,
  side2.start_time AS start_time,
  side2.end_time as end_time,
  side2.report_date AS date,
  side2.resource AS resource,
  side2.message_id AS message_id,
  side2.message AS message,
  side2.regenerate AS regenerate
FROM (
  SELECT
    'a' AS field1,
    start_time,
    LEAD(start_time, 1) OVER (PARTITION BY message_id ORDER BY start_time) AS next_time
  FROM
    [YOUR_PROJECT_ID:logs.bvi_logs]
  WHERE
    message_id = 'start' and resource = "exec_manager") side1
JOIN (
  SELECT
    'a' AS field2,
    *
  FROM
    [YOUR_PROJECT_ID:logs.bvi_logs] ) side2
ON
  side1.field1 = side2.field2
WHERE
  side2.start_time >= side1.start_time
  AND (side2.start_time < next_time
    OR next_time IS NULL)
order by side1.start_time, side2.start_time