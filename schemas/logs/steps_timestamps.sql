SELECT
  side1.start_time AS start_time,
  side1.next_time AS next_time,
  MAX(time_usec) OVER (PARTITION BY start_time, resource ORDER BY start_time, resource) AS max_timestamp,
  side2.time_usec AS time_usec,
  side2.date AS date,
  side2.resource AS resource,
  side2.message_id AS message_id,
  side2.message AS message,
  side2.regenerate AS regenerate
FROM (
  SELECT
    'a' AS field1,
    time_usec AS start_time,
    LEAD(time_usec, 1) OVER (PARTITION BY message_id ORDER BY time_usec) AS next_time
  FROM
    [logs.raw_logs]
  WHERE
    message_id = 'start') side1
JOIN (
  SELECT
    'a' AS field2,
    *
  FROM
    [YOUR_PROJECT_ID:logs.raw_logs] ) side2
ON
  side1.field1 = side2.field2
WHERE
  time_usec >= start_time
  AND (time_usec < next_time
    OR next_time IS NULL)
order by start_time, time_usec