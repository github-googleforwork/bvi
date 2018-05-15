-- required name of view: content_daily
-- Review: 20/02/2017
SELECT
  date, 
  IFNULL(ou, 'NA') AS ou,
  SUM( active_users) AS active_users,
  SUM( readers ) AS readers,
  SUM( editors ) AS editors,
  SUM( num_drive_files_all_included ) AS num_drive_files_all_included,
  SUM( num_non_native_files ) AS num_non_native_files,
  SUM( num_drawings ) AS num_drawings,
  SUM( num_forms ) AS num_forms,
  SUM( num_presentations ) AS num_presentations,
  SUM( num_spreadsheets ) AS num_spreadsheets,
  SUM( num_text_documents ) AS num_text_documents
FROM
  [YOUR_PROJECT_ID:adoption.google_drive_adoption_stats_per_day_per_ou]
WHERE
  _PARTITIONTIME = YOUR_TIMESTAMP_PARAMETER
GROUP BY 1, 2