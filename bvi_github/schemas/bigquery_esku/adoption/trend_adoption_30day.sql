-- trend_adoption_30day
-- Review: 01/03/2018

SELECT
  date AS date,
  doc_adoption_30day,
  slides_adoption_30day,
  forms_adoption_30day,
  sheets_adoption_30day,
  drive_adoption_30day,
  gmail_adoption_30day,
  active_users_1day,
  active_users_30day,
  total_users_30day,
  ROUND(doc_adoption_30day/drive_adoption_30day, 2) AS p_doc_adoption,
  ROUND(slides_adoption_30day/drive_adoption_30day, 2) AS p_slides_adoption,
  ROUND(sheets_adoption_30day/drive_adoption_30day, 2) AS p_sheets_adoption,
  ROUND(forms_adoption_30day/drive_adoption_30day, 2) AS p_forms_adoption,
  ROUND((CASE
        WHEN doc_adoption_30day > sheets_adoption_30day THEN doc_adoption_30day
        ELSE sheets_adoption_30day END) /drive_adoption_30day, 2) AS p_collaboration_adoption,
  ROUND(drive_adoption_30day/active_users_30day, 2) AS p_drive_adoption,
  ROUND(gmail_adoption_30day/active_users_30day, 2) AS p_gmail_adoption,
  ROUND(active_users_30day/total_users_30day, 2) AS p_active_users
FROM
  [YOUR_PROJECT_ID:adoption.adoption_30day]
WHERE
  date IN (
  SELECT
    MAX(date)
  FROM (
    SELECT
      DATE(date) AS date,
      MONTH(DATE(date)) AS month
    FROM
      [YOUR_PROJECT_ID:adoption.adoption_30day]
    WHERE
      date >= DATE(DATE_ADD(TIMESTAMP(CURRENT_DATE()), -6, "MONTH"))
      AND DAY(DATE(date)) <= DAY(DATE_ADD(TIMESTAMP(CURRENT_DATE()), -4, "DAY")) )
  GROUP BY
    month)