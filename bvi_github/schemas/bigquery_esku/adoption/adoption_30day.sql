-- adoption_30day
-- Review: 2017-12-04

SELECT
  drive_users.date as date,
  doc_adoption_30day,
  forms_adoption_30day,
  slides_adoption_30day,
  sheets_adoption_30day,
  drawing_adoption_30day,
  drive_adoption_30day,
  collaboration_adoption_30day,
  gmail_users.count as gmail_adoption_30day,
  active_users_30day.count as active_users_30day,
  active_users_1day.count as active_users_1day,
  total_users_30day.count as total_users_30day
FROM
(SELECT
  date,
  doc_adoption AS doc_adoption_30day,
  forms_adoption AS forms_adoption_30day,
  slides_adoption AS slides_adoption_30day,
  sheets_adoption AS sheets_adoption_30day,
  drawing_adoption AS drawing_adoption_30day,
  drive_adoption AS drive_adoption_30day,
  collaboration_adoption AS collaboration_adoption_30day,
FROM
  [YOUR_PROJECT_ID:users.drive_active_users_30day]
WHERE 
_PARTITIONTIME = TIMESTAMP(YOUR_TIMESTAMP_PARAMETER))drive_users
LEFT JOIN
  [YOUR_PROJECT_ID:users.gmail_active_users_30day] gmail_users
ON
  drive_users.date = gmail_users.date
JOIN
  [YOUR_PROJECT_ID:users.total_active_users_30day] active_users_30day
ON
  drive_users.date = active_users_30day.date
JOIN
  [YOUR_PROJECT_ID:users.total_active_users_1day] active_users_1day
ON
  drive_users.date = active_users_1day.date
JOIN
  [YOUR_PROJECT_ID:users.total_users_30day] total_users_30day
ON
  drive_users.date = total_users_30day.date

