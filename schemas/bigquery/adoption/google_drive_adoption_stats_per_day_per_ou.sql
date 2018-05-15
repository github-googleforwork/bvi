-- google_drive_adoption_stats_per_day_per_ou
-- Review: 16/03/2017
SELECT
  drive_stats.date AS date,
  drive_stats.ou AS ou,
  drive_stats.count_active_users AS active_users,
  IFNULL(text_docs.num_text_documents, 0) AS num_text_documents,
  IFNULL(sheets.num_spreadsheets, 0) AS num_spreadsheets,
  IFNULL(preso.num_presentations, 0) AS num_presentations,
  IFNULL(forms.num_forms, 0) AS num_forms,
  IFNULL(draw.num_drawings, 0) AS num_drawings,
  IFNULL(all.num_docs, 0) AS num_drive_files_all_included,
  IFNULL(non_native.num_non_native_files, 0) AS num_non_native_files,
  ((IFNULL(all.num_docs, 0)) - (IFNULL(non_native.num_non_native_files, 0))) AS num_drive_files,
  SUM(reader) as readers,
  SUM(editor) as editors
FROM (
  SELECT
    date,
    ou,
    SUM(COUNT(email)) AS count_active_users,
    SUM(IF(num_docs_viewed > 0,1,0)) as reader,
    SUM(IF(num_docs_edited > 0,1,0)) as editor
  FROM
    [YOUR_PROJECT_ID:adoption.user_usage_drive_stats_whole_history]
  WHERE
    _PARTITIONTIME = YOUR_TIMESTAMP_PARAMETER
  GROUP BY 1, 2) drive_stats
LEFT JOIN (
  SELECT
    ou,
    SUM(num_text_documents) as num_text_documents
  FROM
    [YOUR_PROJECT_ID:adoption.user_usage_text_documents_daily]
  WHERE
    _PARTITIONTIME = YOUR_TIMESTAMP_PARAMETER
  GROUP BY 1) text_docs
ON
  text_docs.ou = drive_stats.ou
LEFT JOIN (
  SELECT
    ou,
    SUM(num_spreadsheets) as num_spreadsheets
  FROM
    [YOUR_PROJECT_ID:adoption.user_usage_spreadsheets_daily]
  WHERE
    _PARTITIONTIME = YOUR_TIMESTAMP_PARAMETER
  GROUP BY 1) sheets
ON
  sheets.ou = drive_stats.ou
LEFT JOIN (
  SELECT
    ou,
    SUM(num_presentations) as num_presentations
  FROM
    [YOUR_PROJECT_ID:adoption.user_usage_presentations_daily]
  WHERE
    _PARTITIONTIME = YOUR_TIMESTAMP_PARAMETER
  GROUP BY 1) preso
ON
  preso.ou = drive_stats.ou
LEFT JOIN (
  SELECT
    ou,
    SUM(num_forms) as num_forms
  FROM
    [YOUR_PROJECT_ID:adoption.user_usage_forms_daily]
  WHERE
    _PARTITIONTIME = YOUR_TIMESTAMP_PARAMETER
  GROUP BY 1) forms
ON
  forms.ou = drive_stats.ou
LEFT JOIN (
  SELECT
    ou,
    SUM(num_drawings) as num_drawings
  FROM
    [YOUR_PROJECT_ID:adoption.user_usage_drawings_daily]
  WHERE
    _PARTITIONTIME = YOUR_TIMESTAMP_PARAMETER
  GROUP BY 1) draw
ON
  draw.ou = drive_stats.ou
LEFT JOIN (
  SELECT
    ou,
    SUM(num_docs) as num_docs
  FROM
    [YOUR_PROJECT_ID:adoption.user_usage_all_files_daily]
  WHERE
    _PARTITIONTIME = YOUR_TIMESTAMP_PARAMETER
  GROUP BY 1) all
ON
  all.ou = drive_stats.ou
LEFT JOIN (
  SELECT
    ou,
    SUM(num_non_native_files) as num_non_native_files
  FROM
    [YOUR_PROJECT_ID:adoption.user_usage_non_native_files_daily]
  WHERE
    _PARTITIONTIME = YOUR_TIMESTAMP_PARAMETER
  GROUP BY 1) non_native
ON
  non_native.ou = drive_stats.ou
GROUP BY 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11