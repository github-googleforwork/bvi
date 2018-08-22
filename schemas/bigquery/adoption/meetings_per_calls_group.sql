-- meetings_per_calls_group (view)
-- Review: 2018-03-21

SELECT meeting_calls_group, number_meetings, avg_time_spent_meetings, index FROM
(SELECT '2 calls' AS meeting_calls_group, p_num_meetings_with_2_calls AS number_meetings, average_meeting_minutes_with_2_calls AS avg_time_spent_meetings, 1 AS index FROM [YOUR_PROJECT_ID:adoption.meetings_latest_30day_summary]),
(SELECT '3 to 5 calls' AS meeting_calls_group, p_num_meetings_with_3_to_5_calls AS number_meetings, average_meeting_minutes_with_3_to_5_calls AS avg_time_spent_meetings, 2 AS index FROM [YOUR_PROJECT_ID:adoption.meetings_latest_30day_summary]),
(SELECT '6 to 10 calls' AS meeting_calls_group, p_num_meetings_with_6_to_10_calls AS number_meetings, average_meeting_minutes_with_6_to_10_calls AS avg_time_spent_meetings, 3 AS index FROM [YOUR_PROJECT_ID:adoption.meetings_latest_30day_summary]),
(SELECT '11 to 15 calls' AS meeting_calls_group, p_num_meetings_with_11_to_15_calls AS number_meetings, average_meeting_minutes_with_11_to_15_calls AS avg_time_spent_meetings, 4 AS index FROM [YOUR_PROJECT_ID:adoption.meetings_latest_30day_summary]),
(SELECT '16 to 25 calls' AS meeting_calls_group, p_num_meetings_with_16_to_25_calls AS number_meetings, average_meeting_minutes_with_16_to_25_calls AS avg_time_spent_meetings, 5 AS index FROM [YOUR_PROJECT_ID:adoption.meetings_latest_30day_summary]),
(SELECT '26 to 50 calls' AS meeting_calls_group, p_num_meetings_with_26_to_50_calls AS number_meetings, average_meeting_minutes_with_26_to_50_calls AS avg_time_spent_meetings, 6 AS index FROM [YOUR_PROJECT_ID:adoption.meetings_latest_30day_summary]),