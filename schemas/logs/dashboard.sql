SELECT
  IF(pre_dash.side1.resource == 'exec', "=========", DATE(pre_dash.side1.date)) AS report_date,
  DATE(pre_dash_time) AS run_date,
  IF(pre_dash.side1.resource == 'exec', "==============", pre_dash.side1.resource) AS resource,
  pre_dash.side1.start_time AS start_time,
  pre_dash.max_timestamp AS end_time,
  INTEGER(ROUND((max_timestamp - pre_dash.side1.start_time)/1000000, 0)) AS elapsed,
  IF(pre_dash.side1.resource == 'exec', "========", IF(max_timestamp > DATE_ADD(CURRENT_TIMESTAMP(),-5,"MINUTE"), "RUNNING", IF(first_error <= pre_dash_time
        AND count_errors > 0
        AND pre_dash.status = 'ERROR', 'ERROR', IF(first_error <= pre_dash_time
          AND count_errors > 0, 'WARNING', 'SUCCESS')))) AS status,
  IF(first_error <= pre_dash_time
    AND count_errors > 0
    AND pre_dash.status = 'SUCCESS', 'Inconsistent data due to an error in a step before', error_message) AS error_message,
  IF(pre_dash.side1.resource == 'exec', "===============", error_id) AS error_id
FROM (
  SELECT
    SUM(IF(pre_dash.status = 'ERROR',1,0)) OVER (PARTITION BY execs_time) AS count_errors,
    FIRST_VALUE(pre_dash_time) OVER (PARTITION BY execs_time ORDER BY pre_dash.status) AS first_error,
    *
  FROM (
    SELECT
      USEC_TO_TIMESTAMP(max_execs.side1.start_time) execs_time,
      USEC_TO_TIMESTAMP(pre_dash.side1.start_time) pre_dash_time,
      max_execs.*,
      pre_dash.*
    FROM (
      SELECT
        DATE(USEC_TO_TIMESTAMP(side1.start_time)) AS date,
        *
      FROM
        [YOUR_PROJECT_ID:logs.pre_dashboard]
      ORDER BY
        side1.start_time DESC,
        max_timestamp DESC) pre_dash
    JOIN (
      SELECT
        DATE(USEC_TO_TIMESTAMP(side1.start_time)) AS date,
        side1.start_time,
        LEAD(side1.start_time) OVER () AS lead_start_time
      FROM
        [YOUR_PROJECT_ID:logs.pre_dashboard]
      WHERE
        side1.resource = 'exec' ) max_execs
    ON
      pre_dash.date = max_execs.date
    WHERE
      pre_dash.side1.start_time >= max_execs.side1.start_time
      AND (max_execs.lead_start_time IS NULL
        OR pre_dash.side1.start_time < max_execs.lead_start_time) ) )
ORDER BY
  pre_dash.side1.start_time DESC,
  pre_dash.max_timestamp DESC