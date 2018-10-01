-- daily_status (view)
SELECT
  start_time,
  date,
  report_date,
  IF(SUM(IF(dash.status = 'ERROR', 1, 0)) > 0, 'ERROR', 'SUCCESS') AS status,
  1 as value,
FROM (
  SELECT
    DATE(USEC_TO_TIMESTAMP(max_starts.start_time)) AS date,
    max_starts.start_time AS start_time,
    dash.report_date AS report_date,
    dash.status
  FROM (
    SELECT
      DATE(USEC_TO_TIMESTAMP(start_time)) AS date,
      USEC_TO_TIMESTAMP(start_time) AS start_time,
      report_date,
      MAX(IF(status = '========', USEC_TO_TIMESTAMP(start_time), NULL) ) AS max_start_time
    FROM
      [YOUR_PROJECT_ID:logs.dashboard]
    GROUP BY
      1,2,3 ) max_starts
  JOIN
    [YOUR_PROJECT_ID:logs.dashboard] dash
  ON
    dash.run_date = max_starts.date
  WHERE
    USEC_TO_TIMESTAMP(dash.start_time) >= max_start_time )
GROUP BY
  1,2,3
ORDER BY 1 DESC, 2 DESC