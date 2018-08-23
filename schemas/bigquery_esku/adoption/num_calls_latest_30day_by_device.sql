-- num_calls_latest_30day_by_device (view)
-- Review: 2018-03-19

SELECT device, num_calls FROM
(SELECT 'Android' AS device, p_num_calls_android  AS num_calls FROM [YOUR_PROJECT_ID:adoption.meetings_latest_30day_summary]),
(SELECT 'Ios' AS device, p_num_calls_ios AS num_calls FROM [YOUR_PROJECT_ID:adoption.meetings_latest_30day_summary]),
(SELECT 'Chromebox' AS device, p_num_calls_chromebox AS num_calls FROM [YOUR_PROJECT_ID:adoption.meetings_latest_30day_summary]),
(SELECT 'Chomebase' AS device, p_num_calls_chromebase AS num_calls FROM [YOUR_PROJECT_ID:adoption.meetings_latest_30day_summary]),
(SELECT 'Web' AS device, p_num_calls_web AS num_calls FROM [YOUR_PROJECT_ID:adoption.meetings_latest_30day_summary]),
(SELECT 'Jamboard' AS device, p_num_calls_jamboard AS num_calls FROM [YOUR_PROJECT_ID:adoption.meetings_latest_30day_summary]),
(SELECT 'Unknown' AS device, p_num_calls_unknown AS num_calls FROM [YOUR_PROJECT_ID:adoption.meetings_latest_30day_summary])