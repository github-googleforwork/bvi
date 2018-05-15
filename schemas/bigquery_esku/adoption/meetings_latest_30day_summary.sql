-- meetings_latest_30day_summary
-- Review: 2018-03-19

SELECT
    SUM(total_meeting_minutes) AS total_meeting_minutes,
    SUM(num_meetings) AS num_meetings,
    ROUND(AVG(average_meeting_minutes),2) AS average_meeting_minutes,
    SUM(num_calls) AS num_calls,
    ROUND(SUM(num_meetings_with_2_calls) / SUM(num_meetings),2) AS p_num_meetings_with_2_calls,
    ROUND(SUM(num_meetings_with_3_to_5_calls) / SUM(num_meetings),2) AS p_num_meetings_with_3_to_5_calls,
    ROUND(SUM(num_meetings_with_6_to_10_calls) / SUM(num_meetings),2) AS p_num_meetings_with_6_to_10_calls,
    ROUND(SUM(num_meetings_with_11_to_15_calls) / SUM(num_meetings),2) AS p_num_meetings_with_11_to_15_calls,
    ROUND(SUM(num_meetings_with_16_to_25_calls) / SUM(num_meetings),2) AS p_num_meetings_with_16_to_25_calls,
    ROUND(SUM(num_meetings_with_26_to_50_calls) / SUM(num_meetings),2) AS p_num_meetings_with_26_to_50_calls,
    ROUND(AVG(average_meeting_minutes_with_2_calls),2) AS average_meeting_minutes_with_2_calls,
    ROUND(AVG(average_meeting_minutes_with_3_to_5_calls),2) AS average_meeting_minutes_with_3_to_5_calls,
    ROUND(AVG(average_meeting_minutes_with_6_to_10_calls),2) AS average_meeting_minutes_with_6_to_10_calls,
    ROUND(AVG(average_meeting_minutes_with_11_to_15_calls),2) AS average_meeting_minutes_with_11_to_15_calls,
    ROUND(AVG(average_meeting_minutes_with_16_to_25_calls),2) AS average_meeting_minutes_with_16_to_25_calls,
    ROUND(AVG(average_meeting_minutes_with_26_to_50_calls),2) AS average_meeting_minutes_with_26_to_50_calls,
    ROUND(SUM(num_calls_android) / SUM(num_calls),2) AS p_num_calls_android,
    ROUND(SUM(num_calls_ios) / SUM(num_calls),2) AS p_num_calls_ios,
    ROUND(SUM(num_calls_web) / SUM(num_calls),2) AS p_num_calls_web,
    ROUND(SUM(num_calls_chromebase) / SUM(num_calls),2) AS p_num_calls_chromebase,
    ROUND(SUM(num_calls_chromebox) / SUM(num_calls),2) AS p_num_calls_chromebox,
    ROUND(SUM(num_calls_jamboard) / SUM(num_calls),2) AS p_num_calls_jamboard,
    ROUND(SUM(num_calls_unknown_client) / SUM(num_calls),2) AS p_num_calls_unknown,
    ROUND(SUM(total_call_minutes_by_internal_users) / SUM(total_call_minutes),2) AS p_total_call_minutes_by_internal_users,
    ROUND(SUM(total_call_minutes_by_external_users) / SUM(total_call_minutes),2) AS p_total_call_minutes_by_external_users,
    ROUND(SUM(total_call_minutes_by_pstn_in_users) / SUM(total_call_minutes),2) AS p_total_call_minutes_by_pstn_in_users,
    ROUND(SUM(num_calls_by_internal_users) / SUM(num_calls),2) AS p_total_calls_by_internal_users,
    ROUND(SUM(num_calls_by_external_users) / SUM(num_calls),2) AS p_total_calls_by_external_users,
    ROUND(SUM(num_calls_by_pstn_in_users) / SUM(num_calls),2) AS p_total_calls_by_pstn_in_users,
    ROUND(SUM(num_meetings_with_external_users) / SUM(num_calls),2) AS p_total_meetings_with_external_users,
    ROUND(SUM(num_meetings_with_pstn_in_users) / SUM(num_meetings),2) AS p_total_meetings_with_pstn_in_users
  FROM
    [YOUR_PROJECT_ID:adoption.meetings_adoption_daily]
  WHERE
    date > DATE(DATE_ADD(CURRENT_DATE(),-30,"DAY"))