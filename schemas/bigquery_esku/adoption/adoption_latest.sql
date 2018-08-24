-- adoption_latest (view)

SELECT
  customer_usage.date AS date,
  COUNT (active_users.email) AS active_users,
  customer_usage.num_users AS num_total_users,
  customer_usage.num_suspended_users AS num_suspended_users,
  customer_usage.num_non_suspended_users AS num_non_suspended_users,
  users_30da.count AS num_users_30_days_active,
  customer_usage.docs_adoption AS docs_adoption,
  customer_usage.gmail_adoption AS gmail_adoption,
  customer_usage.gplus_adoption AS gplus_adoption,
  customer_usage.calendar_adoption AS calendar_adoption,
  drive_adoption.users_adopted_drive AS users_adopted_drive,
  ROUND(users_30da.count/customer_usage.num_users, 2) AS P_active_users,
  customer_usage.P_gmail_adoption AS P_gmail_adoption,
  customer_usage.P_calendar_adoption AS P_calendar_adoption,
  customer_usage.P_drive_adoption AS P_drive_adoption,
  customer_usage.P_gplus_adoption AS P_gplus_adoption
FROM (
  SELECT
    usage.date AS date,
    usage.accounts.num_users AS num_total_users,
    usage.accounts.num_suspended_users AS num_suspended_users,
    ( usage.accounts.num_users - usage.accounts.num_suspended_users ) AS num_non_suspended_users,
    usage.drive.num_30day_active_users AS docs_adoption,
    usage.gmail.num_30day_active_users AS gmail_adoption,
    usage.gplus.num_30day_active_users AS gplus_adoption,
    usage.calendar.num_30day_active_users AS calendar_adoption,
    usage.accounts.num_users AS num_users,
    ROUND(usage.gmail.num_30day_active_users/usage.accounts.num_users, 2) AS P_gmail_adoption,
    ROUND(usage.calendar.num_30day_active_users/usage.accounts.num_users, 2) AS P_calendar_adoption,
    ROUND(usage.drive.num_30day_active_users/usage.accounts.num_users, 2) AS P_drive_adoption,
    ROUND(usage.gplus.num_30day_active_users/usage.accounts.num_users, 2) AS P_gplus_adoption
  FROM
    [YOUR_PROJECT_ID:EXPORT_DATASET.usage] usage
  WHERE
    usage.record_type = 'customer') customer_usage
INNER JOIN
  [YOUR_PROJECT_ID:users.active_users] active_users
ON
  customer_usage.date = active_users.date
INNER JOIN
  [YOUR_PROJECT_ID:users.active_users_30da] users_30da
ON
  customer_usage.date = users_30da.date
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