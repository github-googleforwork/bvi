-- content_latest_1d (view)
-- Review: 03/09/2018
SELECT
  date,
  IFNULL(ou, 'NA') AS ou,
  SUM( active_users) AS active_users,
  SUM( readers ) AS readers,
  SUM( editors ) AS editors,
  SUM( num_drive_files_all_included ) AS num_users_drive_files_all_included,
  SUM( num_non_native_files ) AS num_users_non_native_files,
  SUM( num_drawings ) AS num_users_drawings,
  SUM( num_forms ) AS num_users_forms,
  SUM( num_presentations ) AS num_users_presentations,
  SUM( num_spreadsheets ) AS num_users_spreadsheets,
  SUM( num_text_documents ) AS num_users_text_documents
FROM
  [YOUR_PROJECT_ID:adoption.google_drive_adoption_stats_per_day_per_ou]
WHERE
  _PARTITIONTIME >= DATE_ADD((SELECT MAX(date) FROM [YOUR_PROJECT_ID:adoption.adoption_30day]),-7,"DAY")
  AND date = (SELECT MAX(date) FROM [YOUR_PROJECT_ID:adoption.adoption_30day])
GROUP BY 1, 2