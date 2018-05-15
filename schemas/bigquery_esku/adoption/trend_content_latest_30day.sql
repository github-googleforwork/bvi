-- trend_content_latest_30day
-- Review: 01/03/2018

SELECT
  up_to_time AS date,
  ou,
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
FROM (
  SELECT
    date,
    CASE
      WHEN DATE(date) > DATE(DATE_ADD(DATE_ADD(CURRENT_DATE(),-4,"DAY"), -1, "MONTH")) THEN DATE(DATE_ADD(CURRENT_DATE(),-4,"DAY"))
      WHEN DATE(date) > DATE(DATE_ADD(DATE_ADD(CURRENT_DATE(),-4,"DAY"),-2, "MONTH")) THEN DATE(DATE_ADD(DATE_ADD(CURRENT_DATE(),-4,"DAY"),-1, "MONTH"))
      WHEN DATE(date) > DATE(DATE_ADD(DATE_ADD(CURRENT_DATE(),-4,"DAY"),-3, "MONTH")) THEN DATE(DATE_ADD(DATE_ADD(CURRENT_DATE(),-4,"DAY"),-2, "MONTH"))
      WHEN DATE(date) > DATE(DATE_ADD(DATE_ADD(CURRENT_DATE(),-4,"DAY"),-4, "MONTH")) THEN DATE(DATE_ADD(DATE_ADD(CURRENT_DATE(),-4,"DAY"),-3, "MONTH"))
      WHEN DATE(date) > DATE(DATE_ADD(DATE_ADD(CURRENT_DATE(),-4,"DAY"),-5, "MONTH")) THEN DATE(DATE_ADD(DATE_ADD(CURRENT_DATE(),-4,"DAY"),-4, "MONTH"))
      ELSE DATE(DATE_ADD(DATE_ADD(CURRENT_DATE(),-4,"DAY"),-5, "MONTH"))
    END AS up_to_time,
    IFNULL(ou, 'NA') AS ou,
    active_users AS active_users,
    readers AS readers,
    editors AS editors,
    num_drive_files_all_included,
    num_non_native_files,
    num_drawings,
    num_forms,
    num_presentations,
    num_spreadsheets,
    num_text_documents
  FROM
    [YOUR_PROJECT_ID:adoption.google_drive_adoption_stats_per_day_per_ou]
  WHERE
    DATE(date) > DATE(DATE_ADD(DATE_ADD(CURRENT_DATE(),-4,"DAY"),-6,"MONTH")) )
GROUP BY
  1,
  2
ORDER BY
  1 DESC