-- calls_time_spent_latest_30day_by_device (view)
-- Review: 2018-03-21

SELECT date, device, time_spent_call FROM
(SELECT date as date, 'Android' AS device, total_call_minutes_android AS time_spent_call FROM [YOUR_PROJECT_ID:adoption.meetings_adoption_daily]),
(SELECT date as date, 'Ios' AS device, total_call_minutes_ios AS time_spent_call FROM [YOUR_PROJECT_ID:adoption.meetings_adoption_daily]),
(SELECT date as date, 'Chromebox' AS device, total_call_minutes_chromebox AS time_spent_call FROM [YOUR_PROJECT_ID:adoption.meetings_adoption_daily]),
(SELECT date as date, 'Chomebase' AS device, total_call_minutes_chromebase AS time_spent_call FROM [YOUR_PROJECT_ID:adoption.meetings_adoption_daily]),
(SELECT date as date, 'Web' AS device, total_call_minutes_web AS time_spent_call FROM [YOUR_PROJECT_ID:adoption.meetings_adoption_daily]),
(SELECT date as date, 'Jamboard' AS device, total_call_minutes_jamboard AS time_spent_call FROM [YOUR_PROJECT_ID:adoption.meetings_adoption_daily]),
(SELECT date as date, 'Unknown' AS device, total_call_minutes_unknown_client  AS time_spent_call FROM [YOUR_PROJECT_ID:adoption.meetings_adoption_daily])
WHERE date > DATE(DATE_ADD(TIMESTAMP(CURRENT_DATE()), -30, "DAY"))