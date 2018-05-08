-- latest_date
-- Review: 22/02/2017
SELECT
  date,
  SUM(users) AS users,
  SUM(audit_log) AS audit_log,
  SUM(customer_usage) AS customer_usage,
  SUM(user_usage) AS user_usage,
FROM (
  SELECT
    date,
    count AS users
  FROM
    [YOUR_PROJECT_ID:raw_data.latest_date_users_list_date]),
  (
  SELECT
    date,
    count AS audit_log
  FROM
    [YOUR_PROJECT_ID:raw_data.latest_date_audit_log]),
  (
  SELECT
    date,
    count AS customer_usage
  FROM
    [YOUR_PROJECT_ID:raw_data.latest_date_customer_usage]),
  (
  SELECT
    date,
    count AS user_usage
  FROM
    [YOUR_PROJECT_ID:raw_data.latest_date_user_usage]),
GROUP BY 1
ORDER BY 1 DESC