-- adoption_latest (view)
-- Review: 03/04/2017

SELECT
  customer_usage.date AS date,
  COUNT (active_users.email) AS active_users,
  customer_usage.num_users AS num_total_users,
  customer_usage.num_suspended_users AS num_suspended_users,
  ( customer_usage.num_users - customer_usage.num_suspended_users ) AS num_non_suspended_users,
  users_3da.count AS num_users_30_days_active,
  customer_usage.docs_30da AS docs_adoption,
  customer_usage.gmail_30da AS gmail_adoption,
  customer_usage.gplus_30da AS gplus_adoption,
  customer_usage.calendar_30da AS calendar_adoption,
  drive_adoption.users_adopted_drive AS users_adopted_drive,
  ROUND(users_3da.count/customer_usage.num_users, 2) AS P_active_users,
  ROUND(customer_usage.gmail_30da/customer_usage.num_users, 2) AS P_gmail_adoption,
  ROUND(customer_usage.calendar_30da/customer_usage.num_users, 2) AS P_calendar_adoption,
  ROUND(customer_usage.docs_30da/customer_usage.num_users, 2) AS P_drive_adoption,
  ROUND(customer_usage.gplus_30da/customer_usage.num_users, 2) AS P_gplus_adoption
FROM
  [YOUR_PROJECT_ID:adoption.customer_usage_date_summary] customer_usage
INNER JOIN
  [YOUR_PROJECT_ID:users.active_users] active_users
ON
  customer_usage.date = active_users.date
INNER JOIN
  [YOUR_PROJECT_ID:users.active_users_30da] users_3da
ON
  customer_usage.date = users_3da.date
INNER JOIN
  [YOUR_PROJECT_ID:adoption.drive_adoption_per_day_per_ou] drive_adoption
ON
  customer_usage.date = drive_adoption.date
WHERE
  active_users._PARTITIONTIME > DATE_ADD(CURRENT_DATE(),-20,"DAY")
GROUP BY
  1, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16
ORDER BY 1 DESC
LIMIT 1