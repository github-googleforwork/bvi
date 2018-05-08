-- customer_usage_date_summary
-- Review: 07/08/2017
SELECT
  date,
  SUM(CASE WHEN parameters.name IN ('accounts:gsuite_enterprise_used_licenses', 'accounts:gsuite_basic_used_licenses', 'accounts:gsuite_unlimited_used_licenses') THEN (IFNULL(parameters.intValue,NULL)) ELSE 0 END) AS num_users,
  SUM(CASE WHEN parameters.name = 'accounts:num_suspended_users' THEN (IFNULL(parameters.intValue,NULL)) ELSE 0 END) AS num_suspended_users,
  SUM(CASE WHEN parameters.name = 'accounts:num_1day_logins' THEN (IFNULL(parameters.intValue,NULL)) ELSE 0 END) AS num_1day_logins,
  SUM(CASE WHEN parameters.name = 'accounts:num_7day_logins' THEN (IFNULL(parameters.intValue,NULL)) ELSE 0 END) AS num_7day_logins,
  SUM(CASE WHEN parameters.name = 'accounts:num_30day_logins' THEN (IFNULL(parameters.intValue,NULL)) ELSE 0 END) AS num_30day_logins,
  SUM(CASE WHEN parameters.name = 'drive:num_1day_active_users' THEN (IFNULL(parameters.intValue,NULL)) ELSE 0 END) AS docs_1da,
  SUM(CASE WHEN parameters.name = 'drive:num_7day_active_users' THEN (IFNULL(parameters.intValue,NULL)) ELSE 0 END) AS docs_7da,
  SUM(CASE WHEN parameters.name = 'drive:num_30day_active_users' THEN (IFNULL(parameters.intValue,NULL)) ELSE 0 END) AS docs_30da,
  SUM(CASE WHEN parameters.name = 'gmail:num_30day_active_users' THEN (IFNULL(parameters.intValue,NULL)) ELSE 0 END) AS gmail_30da,
  SUM(CASE WHEN parameters.name = 'calendar:num_30day_active_users' THEN (IFNULL(parameters.intValue,NULL)) ELSE 0 END) AS calendar_30da,
  SUM(CASE WHEN parameters.name = 'gplus:num_30day_active_users' THEN (IFNULL(parameters.intValue,NULL)) ELSE 0 END) AS gplus_30da,
  SUM(CASE WHEN parameters.name = 'docs:num_docs' THEN (IFNULL(parameters.intValue,NULL)) ELSE 0 END) AS num_docs_customer
FROM
  [YOUR_PROJECT_ID:raw_data.customer_usage]
WHERE TRUE
  AND _PARTITIONTIME = YOUR_TIMESTAMP_PARAMETER
GROUP BY 1