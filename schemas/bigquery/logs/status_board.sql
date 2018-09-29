-- status_board (view)

SELECT
  report_date, SUM(IF(status = 'ERROR',1,0)) status
FROM (
  SELECT
    dash.report_date AS report_date,
    TIMESTAMP(last.last_executed) AS last_executed,
    dash.status AS status
  FROM
    [YOUR_PROJECT_ID:logs.dashboard] dash
  JOIN
    [YOUR_PROJECT_ID:logs.last_executed] last
  ON
    last.report_date = dash.report_date
  WHERE
    dash.start_time >= last.last_executed
    AND dash.status != '========'
  GROUP BY 1, 2, 3 )
GROUP BY 1
ORDER BY 1 DESC