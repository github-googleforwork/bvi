-- bvi_logs (view)
SELECT
  *,
  INTEGER(ROUND((end_time - start_time)/1000000, 0)) AS elapsed,
FROM (
  SELECT
    date AS report_date,
    time_usec AS start_time,
    LEAD(time_usec) OVER () AS end_time,
    resource,
    message_id,
    message,
    regenerate
  FROM
    [YOUR_PROJECT_ID:logs.raw_logs]
  ORDER BY
    time_usec )
WHERE
  message_id != 'end'