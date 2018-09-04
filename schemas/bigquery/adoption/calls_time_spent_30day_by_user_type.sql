-- calls_time_spent_30day_by_user_type (view)
-- Review: 2018-03-23

SELECT date, user_type, time_spent_call FROM
(SELECT date AS date, 'Internal Users' AS user_type, total_call_minutes_by_internal_users AS time_spent_call FROM [YOUR_PROJECT_ID:adoption.meetings_30day_summary]),
(SELECT date AS date, 'External Users' AS user_type, total_call_minutes_by_external_users AS time_spent_call FROM [YOUR_PROJECT_ID:adoption.meetings_30day_summary]),
(SELECT date AS date, 'PSTN in Users' AS user_type, total_call_minutes_by_pstn_in_users AS time_spent_call FROM [YOUR_PROJECT_ID:adoption.meetings_30day_summary]),
WHERE date >= DATE(DATE_ADD((SELECT MAX(date) FROM [YOUR_PROJECT_ID:adoption.adoption_30day]), -30, "DAY"))