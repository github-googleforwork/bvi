-- pre_dashboard (view)
SELECT
  side1.date,
  side1.start_time,
  side1.resource,
  side1.end_time,
  IF(side1.message_id = 'start', 'SUCCESS', 'ERROR') AS status,
  IF(side1.message_id = 'start', '', side2.message_id) AS error_id,
  IF(side1.message_id = 'start', '', side2.message) AS error_message,
  count(*) AS errors_qty
FROM
  [YOUR_PROJECT_ID:logs.steps_timestamps] side1
LEFT JOIN (
  SELECT
    start_time,
    resource,
    message_id,
    message
  FROM
    [YOUR_PROJECT_ID:logs.steps_timestamps]
  WHERE
    regenerate = 'True') side2
ON
  side1.start_time=side2.start_time
GROUP BY
  side1.date,
  side1.start_time,
  side1.resource,
  side1.end_time,
  status,
  error_id,
  error_message
ORDER BY
  2,4