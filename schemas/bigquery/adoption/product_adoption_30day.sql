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
  SUM(adoption.gplus) AS gplus
FROM
(SELECT
  DATE(YOUR_TIMESTAMP_PARAMETER) AS date,
  data_email,
  SUM(EXACT_COUNT_DISTINCT(data_email)) AS active_users_total,
  SUM( CASE WHEN application_name = 'drive' AND parameters_name = 'doc_type' AND product = 'document' THEN (INTEGER(EXACT_COUNT_DISTINCT(data_email))) ELSE 0 END ) as document,
  SUM( CASE WHEN application_name = 'drive' AND parameters_name = 'doc_type' AND product = 'drawing' THEN (INTEGER(EXACT_COUNT_DISTINCT(data_email))) ELSE 0 END ) as drawing,
  SUM( CASE WHEN application_name = 'drive' AND parameters_name = 'doc_type' AND product = 'folder' THEN (INTEGER(EXACT_COUNT_DISTINCT(data_email))) ELSE 0 END ) as folder,
  SUM( CASE WHEN application_name = 'drive' AND parameters_name = 'doc_type' AND product = 'form' THEN (INTEGER(EXACT_COUNT_DISTINCT(data_email))) ELSE 0 END ) as form,
  SUM( CASE WHEN application_name = 'drive' AND parameters_name = 'doc_type' AND product = 'presentation' THEN (INTEGER(EXACT_COUNT_DISTINCT(data_email))) ELSE 0 END ) as presentation,
  SUM( CASE WHEN application_name = 'drive' AND parameters_name = 'doc_type' AND product = 'spreadsheet' THEN (INTEGER(EXACT_COUNT_DISTINCT(data_email))) ELSE 0 END ) as spreadsheet,
  SUM( CASE WHEN application_name = 'drive' AND parameters_name = 'doc_type' AND product = 'unknown' THEN (INTEGER(EXACT_COUNT_DISTINCT(data_email))) ELSE 0 END ) as unknown,
  SUM( CASE WHEN application_name = 'calendar' THEN (INTEGER(EXACT_COUNT_DISTINCT(data_email))) ELSE 0 END ) as calendar,
  SUM( CASE WHEN application_name = 'gplus' THEN (INTEGER(EXACT_COUNT_DISTINCT(data_email))) ELSE 0 END ) as gplus
FROM (
  SELECT
    STRFTIME_UTC_USEC(id.time,"%Y-%m-%d") AS date,
    actor.email AS data_email,
    events.type,
    events.name,
    events.parameters.value AS product,
    id.applicationName as application_name,
    events.parameters.name AS parameters_name,
    INTEGER(COUNT(*)) AS event
  FROM
    [YOUR_PROJECT_ID:raw_data.audit_log]
  WHERE
    TRUE
    AND _PARTITIONTIME >= DATE_ADD(YOUR_TIMESTAMP_PARAMETER, -30, "DAY")
    AND _PARTITIONTIME < DATE_ADD(YOUR_TIMESTAMP_PARAMETER,1,"DAY")
    AND events.type IS NOT NULL
    AND events.parameters.name = 'doc_type'
  GROUP BY 1, 2, 3, 4, 5, 6, 7) data
GROUP BY 1, 2, product, application_name, parameters_name) adoption
LEFT JOIN (
  SELECT ou, email
  FROM
    [YOUR_PROJECT_ID:users.users_ou_list]
  WHERE
    TRUE
    AND _PARTITIONTIME >= DATE_ADD(YOUR_TIMESTAMP_PARAMETER, -30, "DAY")
    AND _PARTITIONTIME < DATE_ADD(YOUR_TIMESTAMP_PARAMETER,1,"DAY") GROUP by 1,2) users
ON
  users.email = adoption.data_email
GROUP BY 1, 2