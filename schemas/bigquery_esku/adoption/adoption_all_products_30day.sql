-- adoption_all_products_30day (view)

SELECT
  adoption_30day.date AS date,
  adoption_30day.doc_adoption_30day AS doc_adoption_30day,
  adoption_30day.forms_adoption_30day AS forms_adoption_30day,
  adoption_30day.slides_adoption_30day AS slides_adoption_30day,
  adoption_30day.sheets_adoption_30day AS sheets_adoption_30day,
  adoption_30day.drawing_adoption_30day AS drawing_adoption_30day,
  adoption_30day.drive_adoption_30day AS drive_adoption_30day,
  adoption_30day.collaboration_adoption_30day AS collaboration_adoption_30day,
  adoption_30day.gmail_adoption_30day AS gmail_adoption_30day,
  adoption_30day.active_users_30day AS active_users_30day,
  adoption_30day.active_users_1day AS active_users_1day,
  adoption_30day.total_users_30day AS total_users_30day,
  meeting_adoption.meet_adoption_30day AS meet_adoption_30day,
  adoption.gplus_adoption as gplus_adoption_30day,
  adoption.calendar_adoption as calendar_adoption_30day
FROM
  [YOUR_PROJECT_ID:adoption.adoption_30day] AS adoption_30day
JOIN
  [YOUR_PROJECT_ID:adoption.adoption] AS adoption
ON
  adoption.date = adoption_30day.date
LEFT JOIN (
  SELECT
    date,
    num_30day_active_users AS meet_adoption_30day,
  FROM
    [YOUR_PROJECT_ID:adoption.meetings_adoption_daily]) meeting_adoption
ON
  adoption_30day.date = meeting_adoption.date