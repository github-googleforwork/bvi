-- calls_by_users_type_pie_chart
-- Review: 2018-03-21

SELECT user_type, number_of_calls, calls_time_spent, index FROM
(SELECT 'Internal Users' AS user_type, p_total_calls_by_internal_users AS number_of_calls, p_total_call_minutes_by_internal_users AS calls_time_spent, 1 AS index FROM [YOUR_PROJECT_ID:adoption.meetings_latest_30day_summary]),
(SELECT 'External Users' AS user_type, p_total_calls_by_external_users AS number_of_calls, p_total_call_minutes_by_external_users AS calls_time_spent, 2 AS index FROM [YOUR_PROJECT_ID:adoption.meetings_latest_30day_summary]),
(SELECT 'PSTN in Users' AS user_type, p_total_calls_by_pstn_in_users AS number_of_calls, p_total_call_minutes_by_pstn_in_users AS calls_time_spent, 3 AS index FROM [YOUR_PROJECT_ID:adoption.meetings_latest_30day_summary])