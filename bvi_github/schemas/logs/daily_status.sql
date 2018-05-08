SELECT
  date,
  IF(SUM(IF(dash.status = 'ERROR', 1, 0)) > 0, 'ERROR', 'SUCCESS') AS status,
  1 as value,
FROM (
  SELECT
    max_starts.date AS date,
    dash.status
  FROM (
    SELECT
      DATE(USEC_TO_TIMESTAMP(start_time)) AS date,
      MAX(IF(status = '========', USEC_TO_TIMESTAMP(start_time), NULL) ) AS max_start_time
    FROM
      [YOUR_PROJECT_ID:logs.dashboard]
    GROUP BY
      1 ) max_starts
  JOIN
    [YOUR_PROJECT_ID:logs.dashboard] dash
  ON
    dash.run_date = max_starts.date
  WHERE
    USEC_TO_TIMESTAMP(dash.start_time) >= max_start_time )
GROUP BY
  1