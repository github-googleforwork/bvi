-- product_adoption_latest_30d (view)
-- Review: 04/12/2018
SELECT
  final.ou AS ou,
  final.adoption_users AS adoption_users,
  final.active_users AS active_users,
  final.users_adopting_documents AS users_adopting_documents,
  final.users_adopting_spreadsheets AS users_adopting_spreadsheets,
  final.users_adopting_presentations AS users_adopting_presentations,
  final.users_adopting_forms AS users_adopting_forms,
  final.users_adopting_folders AS users_adopting_folders,
  final.users_adopting_drawings AS users_adopting_drawings,
  final.users_adopting_other_files AS users_adopting_other_files,
  final.users_adopting_drive as users_adopting_drive,
  ROUND (final.users_adopting_documents/final.active_users, 2) AS P_docs_adoption,
  ROUND (final.users_adopting_spreadsheets/final.active_users, 2) AS P_sheets_adoption,
  ROUND (final.users_adopting_forms/final.active_users, 2) AS P_form_adoption,
  ROUND (final.users_adopting_presentations/final.active_users, 2) AS P_preso_adoption,
  ROUND (final.adoption_users/final.active_users, 2) AS P_Collaboration_adoption,
  ROUND (final.users_adopting_drive/final.active_users, 2) AS P_drive_adoption
  FROM (
SELECT
  users.ou AS ou,
  active_users.count AS active_users,
  SUM(active_users_total) AS adoption_users,
  SUM(document) AS users_adopting_documents,
  SUM(drawing) AS users_adopting_drawings,
  SUM(folder) AS users_adopting_folders,
  SUM(form) AS users_adopting_forms,
  SUM(presentation) AS users_adopting_presentations,
  SUM(spreadsheet) AS users_adopting_spreadsheets,
  SUM(unknown) AS users_adopting_other_files,
  SUM(drive.users_adopting_drive) as users_adopting_drive
FROM
(SELECT
    data_email,
    SUM(EXACT_COUNT_DISTINCT(data_email)) AS active_users_total,
    SUM( CASE WHEN product = 'document' THEN (INTEGER(EXACT_COUNT_DISTINCT(data_email))) ELSE 0 END ) as document,
    SUM( CASE WHEN product = 'drawing' THEN (INTEGER(EXACT_COUNT_DISTINCT(data_email))) ELSE 0 END ) as drawing,
    SUM( CASE WHEN product = 'folder' THEN (INTEGER(EXACT_COUNT_DISTINCT(data_email))) ELSE 0 END ) as folder,
    SUM( CASE WHEN product = 'form' THEN (INTEGER(EXACT_COUNT_DISTINCT(data_email))) ELSE 0 END ) as form,
    SUM( CASE WHEN product = 'presentation' THEN (INTEGER(EXACT_COUNT_DISTINCT(data_email))) ELSE 0 END ) as presentation,
    SUM( CASE WHEN product = 'spreadsheet' THEN (INTEGER(EXACT_COUNT_DISTINCT(data_email))) ELSE 0 END ) as spreadsheet,
    SUM( CASE WHEN product = 'unknown' THEN (INTEGER(EXACT_COUNT_DISTINCT(data_email))) ELSE 0 END ) as unknown
FROM (
    SELECT
      email AS data_email,
      drive.doc_type AS product,
      INTEGER(COUNT(*)) AS event
    FROM
      [YOUR_PROJECT_ID:Reports.activity] AS audit
    WHERE
      TRUE
      AND _PARTITIONTIME >= DATE_ADD((SELECT MAX(date) FROM [YOUR_PROJECT_ID:adoption.adoption_30day]), -30, "DAY")
      AND TIMESTAMP(STRFTIME_UTC_USEC(time_usec,"%Y-%m-%d")) >= DATE_ADD((SELECT MAX(date) FROM [YOUR_PROJECT_ID:adoption.adoption_30day]),-30,"DAY")
      AND TIMESTAMP(STRFTIME_UTC_USEC(time_usec,"%Y-%m-%d")) <= TIMESTAMP((SELECT MAX(date) FROM [YOUR_PROJECT_ID:adoption.adoption_30day]))
      AND record_type  = 'drive'
      AND event_type IS NOT NULL
      GROUP BY 1,2) data
        GROUP BY 1, product) adoption
  INNER JOIN (
    SELECT
      email,
      IFNULL(ou, 'NA') AS ou
    FROM
      [YOUR_PROJECT_ID:users.users_ou_list]
    WHERE
      TRUE
      AND _PARTITIONTIME >= DATE_ADD((SELECT MAX(date) FROM [YOUR_PROJECT_ID:adoption.adoption_30day]),-30,"DAY")
    GROUP BY 1,2) users
  ON
    users.email = adoption.data_email
LEFT JOIN
(SELECT
  email,
  EXACT_COUNT_DISTINCT(email) as users_adopting_drive
FROM
  [YOUR_PROJECT_ID:adoption.audit_log_drive_adoption_per_day]
WHERE
  _PARTITIONTIME >= DATE_ADD((SELECT MAX(date) FROM [YOUR_PROJECT_ID:adoption.adoption_30day]),-30,"DAY")
GROUP BY 1) drive
ON
  users.email = drive.email
  INNER JOIN
  (
    SELECT
      ou, COUNT((email)) as count
    FROM
      [YOUR_PROJECT_ID:users.active_users_with_ou_per_day]
    WHERE
      _PARTITIONTIME >= DATE_ADD((SELECT MAX(date) FROM [YOUR_PROJECT_ID:adoption.adoption_30day]),-30,"DAY")
    GROUP BY 1
  ) active_users
ON
  users.ou = active_users.ou
GROUP BY
  ou, active_users
  ) final
  GROUP BY 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17