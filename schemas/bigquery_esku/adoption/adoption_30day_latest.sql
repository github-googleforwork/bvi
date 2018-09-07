-- adoption_30day_latest (view)
-- Review: 2018-03-05

SELECT
  latest_adoption.date AS date,
  latest_adoption.doc_adoption_30day AS doc_adoption_30day,
  latest_adoption.slides_adoption_30day AS slides_adoption_30day,
  latest_adoption.forms_adoption_30day AS forms_adoption_30day,
  latest_adoption.sheets_adoption_30day AS sheets_adoption_30day,
  latest_adoption.drawing_adoption_30day AS drawing_adoption_30day,
  latest_adoption.drive_adoption_30day AS drive_adoption_30day,
  latest_adoption.collaboration_adoption_30day AS collaboration_adoption_30day,
  latest_adoption.gmail_adoption_30day AS gmail_adoption_30day,
  latest_adoption.active_users_1day AS active_users_1day,
  latest_adoption.active_users_30day AS active_users_30day,
  latest_adoption.total_users_30day AS total_users_30day,
  latest_meeting_adoption.meetings_active_users_30day as meetings_active_users_30day,
  ROUND(latest_adoption.doc_adoption_30day/latest_adoption.active_users_30day, 2) as p_doc_adoption,
  ROUND(latest_adoption.slides_adoption_30day/latest_adoption.active_users_30day, 2) as p_slides_adoption,
  ROUND(latest_adoption.sheets_adoption_30day/latest_adoption.active_users_30day, 2) as p_sheets_adoption,
  ROUND(latest_adoption.forms_adoption_30day/latest_adoption.active_users_30day, 2) as p_forms_adoption,
  ROUND(latest_adoption.drawing_adoption_30day/latest_adoption.active_users_30day, 2) as p_drawing_adoption,
  ROUND(latest_adoption.collaboration_adoption_30day/latest_adoption.active_users_30day, 2)  as p_collaboration_adoption,
  ROUND(latest_adoption.drive_adoption_30day/latest_adoption.active_users_30day, 2) as p_drive_adoption,
  ROUND(latest_adoption.gmail_adoption_30day/latest_adoption.active_users_30day, 2) as p_gmail_adoption,
  ROUND(latest_adoption.active_users_30day/latest_adoption.total_users_30day, 2) as p_active_users,
  ROUND(latest_meeting_adoption.meetings_active_users_30day/latest_adoption.total_users_30day, 2) as p_meet_adoption
FROM
  [YOUR_PROJECT_ID:adoption.adoption_30day] latest_adoption
LEFT JOIN (
SELECT
  date, num_30day_active_users as meetings_active_users_30day,
FROM
  [YOUR_PROJECT_ID:adoption.meetings_adoption_daily]) latest_meeting_adoption
  ON latest_adoption.date = latest_meeting_adoption.date
WHERE
  latest_adoption.date = (SELECT MAX(date) FROM [YOUR_PROJECT_ID:adoption.adoption_30day])