-- meetings_by_users_type_pie_chart (view)
-- Review: 2018-03-19

SELECT user_type, meetings_with, index FROM
(SELECT 'Only Internal Users' AS user_type, (1 - p_total_meetings_with_external_users - p_total_meetings_with_pstn_in_users) AS meetings_with,1 AS index FROM [YOUR_PROJECT_ID:adoption.meetings_latest_30day_summary]),
(SELECT 'With External Users' AS user_type, p_total_meetings_with_external_users AS meetings_with,2 AS index FROM [YOUR_PROJECT_ID:adoption.meetings_latest_30day_summary]),
(SELECT 'With PSTN in Users' AS user_type, p_total_meetings_with_pstn_in_users AS meetings_with,3 AS index FROM [YOUR_PROJECT_ID:adoption.meetings_latest_30day_summary])