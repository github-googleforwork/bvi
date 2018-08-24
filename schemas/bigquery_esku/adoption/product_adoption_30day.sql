-- product_adoption_30day
SELECT
  DATE(YOUR_TIMESTAMP_PARAMETER) AS date,
  IFNULL(users.ou, 'NA') AS ou,
  SUM(EXACT_COUNT_DISTINCT(adoption.data_email)) AS active_users_total,
  SUM(adoption.document) AS document,
  SUM(adoption.spreadsheet) AS spreadsheet,
  SUM(adoption.presentation) AS presentation,
  SUM(adoption.form) AS form,
  SUM(adoption.drawing) AS drawing,
  SUM(adoption.folder) AS folder,
  SUM(adoption.unknown) AS unknown,
  SUM(adoption.calendar) AS calendar,
  SUM(adoption.gplus) AS gplus,
FROM
(SELECT
  DATE(YOUR_TIMESTAMP_PARAMETER) AS date,
  data_email,
  SUM(EXACT_COUNT_DISTINCT(data_email)) AS active_users_total,
  SUM( CASE WHEN record_type = 'drive' AND product = 'document' THEN (INTEGER(EXACT_COUNT_DISTINCT(data_email))) ELSE 0 END ) as document,
  SUM( CASE WHEN record_type = 'drive' AND product = 'drawing' THEN (INTEGER(EXACT_COUNT_DISTINCT(data_email))) ELSE 0 END ) as drawing,
  SUM( CASE WHEN record_type = 'drive' AND product = 'folder' THEN (INTEGER(EXACT_COUNT_DISTINCT(data_email))) ELSE 0 END ) as folder,
  SUM( CASE WHEN record_type = 'drive' AND product = 'form' THEN (INTEGER(EXACT_COUNT_DISTINCT(data_email))) ELSE 0 END ) as form,
  SUM( CASE WHEN record_type = 'drive' AND product = 'presentation' THEN (INTEGER(EXACT_COUNT_DISTINCT(data_email))) ELSE 0 END ) as presentation,
  SUM( CASE WHEN record_type = 'drive' AND product = 'spreadsheet' THEN (INTEGER(EXACT_COUNT_DISTINCT(data_email))) ELSE 0 END ) as spreadsheet,
  SUM( CASE WHEN record_type = 'drive' AND product = 'unknown' THEN (INTEGER(EXACT_COUNT_DISTINCT(data_email))) ELSE 0 END ) as unknown,
  SUM( CASE WHEN record_type = 'calendar' THEN (INTEGER(EXACT_COUNT_DISTINCT(data_email))) ELSE 0 END ) as calendar,
  SUM( CASE WHEN record_type = 'gplus' THEN (INTEGER(EXACT_COUNT_DISTINCT(data_email))) ELSE 0 END ) as gplus,
FROM (
  SELECT *, INTEGER(COUNT(*)) AS event FROM (
    SELECT
      STRFTIME_UTC_USEC(time_usec,"%Y-%m-%d") AS date,
      email as data_email,
      event_type,
      event_name,
      drive.doc_type AS product,
      record_type,
      NTH(2, SPLIT(email, '@')) AS domain
    FROM
      [YOUR_PROJECT_ID:EXPORT_DATASET.activity]
    WHERE
      TRUE
      AND _PARTITIONTIME >= DATE_ADD(YOUR_TIMESTAMP_PARAMETER, -31, "DAY")
      AND _PARTITIONTIME < DATE_ADD(YOUR_TIMESTAMP_PARAMETER,2,"DAY")
      AND TIMESTAMP(STRFTIME_UTC_USEC(time_usec,"%Y-%m-%d")) >= DATE_ADD(YOUR_TIMESTAMP_PARAMETER,-30,"DAY")
      AND TIMESTAMP(STRFTIME_UTC_USEC(time_usec,"%Y-%m-%d")) < DATE_ADD(YOUR_TIMESTAMP_PARAMETER,1,"DAY")
      AND event_type IS NOT NULL)
  GROUP BY
    1, 2, 3, 4, 5, 6, 7) data
  WHERE
    domain IN ( YOUR_DOMAINS )
GROUP BY 1, 2, product, record_type) adoption
LEFT JOIN (
  SELECT ou, email
  FROM
    [YOUR_PROJECT_ID:users.users_ou_list]
  WHERE
    TRUE
    AND _PARTITIONTIME >= DATE_ADD(YOUR_TIMESTAMP_PARAMETER, -30, "DAY")
    AND _PARTITIONTIME <= DATE_ADD(YOUR_TIMESTAMP_PARAMETER, 1,"DAY") GROUP by 1,2) users
ON
  users.email = adoption.data_email
GROUP BY 1, 2