-- CUSTOM custom_product_adoption_daily
-- Review: 18/07/2018
SELECT
  adoption.date AS date,
  IFNULL(users.ou, 'undefined') AS ou,
  IFNULL(users.custom_1, 'undefined') AS custom_1,
  IFNULL(users.custom_2, 'undefined') AS custom_2,
  IFNULL(users.custom_3, 'undefined') AS custom_3,
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
  DATE(YOUR_TIMESTAMP_PARAMETER) as date,
  data_email,
  SUM( CASE WHEN app = 'document' THEN (INTEGER(EXACT_COUNT_DISTINCT(data_email))) ELSE 0 END ) as document,
  SUM( CASE WHEN app = 'drawing' THEN (INTEGER(EXACT_COUNT_DISTINCT(data_email))) ELSE 0 END ) as drawing,
  SUM( CASE WHEN app = 'spreadsheet' THEN (INTEGER(EXACT_COUNT_DISTINCT(data_email))) ELSE 0 END ) as spreadsheet,
  SUM( CASE WHEN app = 'presentation' THEN (INTEGER(EXACT_COUNT_DISTINCT(data_email))) ELSE 0 END ) as presentation,
  SUM( CASE WHEN app = 'folder' THEN (INTEGER(EXACT_COUNT_DISTINCT(data_email))) ELSE 0 END ) as folder,
  SUM( CASE WHEN app = 'form' THEN (INTEGER(EXACT_COUNT_DISTINCT(data_email))) ELSE 0 END ) as form,
  SUM( CASE WHEN app = 'unknown' THEN (INTEGER(EXACT_COUNT_DISTINCT(data_email))) ELSE 0 END ) as unknown,
  SUM( CASE WHEN app = 'calendar' THEN (INTEGER(EXACT_COUNT_DISTINCT(data_email))) ELSE 0 END ) as calendar,
  SUM( CASE WHEN app = 'gplus' THEN (INTEGER(EXACT_COUNT_DISTINCT(data_email))) ELSE 0 END ) as gplus
FROM (
  SELECT
    id.time,
    STRFTIME_UTC_USEC(id.time,"%Y-%m-%d") AS date,
    actor.email AS data_email,
    CASE
      WHEN id.applicationName = 'drive' AND events.parameters.name = 'doc_type' AND events.parameters.value = 'document' THEN 'document'
      WHEN id.applicationName = 'drive' AND events.parameters.name = 'doc_type' AND events.parameters.value = 'drawing' THEN 'drawing'
      WHEN id.applicationName = 'drive' AND events.parameters.name = 'doc_type' AND events.parameters.value = 'spreadsheet' THEN 'spreadsheet'
      WHEN id.applicationName = 'drive' AND events.parameters.name = 'doc_type' AND events.parameters.value = 'presentation' THEN 'presentation'
      WHEN id.applicationName = 'drive' AND events.parameters.name = 'doc_type' AND events.parameters.value = 'folder' THEN 'folder'
      WHEN id.applicationName = 'drive' AND events.parameters.name = 'doc_type' AND events.parameters.value = 'form' THEN 'form'
      WHEN id.applicationName = 'drive' AND events.parameters.name = 'doc_type' AND events.parameters.value = 'unknown' THEN 'unknown'
      WHEN id.applicationName = 'calendar' THEN 'calendar'
      WHEN id.applicationName = 'gplus' THEN 'gplus'
    END AS app
  FROM
    [YOUR_PROJECT_ID:raw_data.audit_log]
  WHERE
    TRUE
    AND _PARTITIONTIME = YOUR_TIMESTAMP_PARAMETER
    AND id.applicationName IN ('drive', 'calendar', 'gplus')
    AND events.type IS NOT NULL) data
GROUP BY 1, 2, app) adoption
LEFT JOIN (
  SELECT users_ou_list.ou AS ou,
  users_ou_list.email AS email,
  custom.custom_1 AS custom_1,
  custom.custom_2 AS custom_2,
  custom.custom_3 AS custom_3
  FROM
    [YOUR_PROJECT_ID:users.users_ou_list] users_ou_list
  LEFT JOIN
    (SELECT email, custom_1, custom_2, custom_3, FROM [YOUR_PROJECT_ID:custom.raw_custom_fields] GROUP BY 1,2,3,4) custom
    ON users_ou_list.email = custom.email
  WHERE
    TRUE
    AND users_ou_list._PARTITIONTIME = YOUR_TIMESTAMP_PARAMETER
    GROUP BY 1, 2, 3, 4, 5) users
ON
  users.email = adoption.data_email
GROUP BY 1, 2, 3, 4, 5