-- adoption
SELECT
  customer_usage.date as date,
  customer_usage.num_users AS num_total_users,
  customer_usage.num_suspended_users AS num_suspended_users,
  ( customer_usage.num_users - customer_usage.num_suspended_users ) AS num_non_suspended_users,
  active_users.count as active_users_1d,
  customer_usage.logins_30_day_active as active_users_30_days,
  customer_usage.docs_30_day_active AS docs_adoption,
  customer_usage.gmail_30_day_active AS gmail_adoption,
  customer_usage.gplus_30_day_active AS gplus_adoption,
  customer_usage.calendar_30_day_active AS calendar_adoption,
  num_docs.total_num_docs AS total_num_docs,
  drive_adoption.active_users as active_users_drive,
  drive_adoption.users_adopted_drive as users_adopted_drive,
  editor_adoption.active_users as active_users_editor,
  editor_adoption.editor_users as editor_adoption,
FROM
  (
     SELECT
      stats.date AS date,
      (stats.accounts.num_users) AS num_users,
      (stats.accounts.num_suspended_users) AS num_suspended_users,
      (stats.accounts.num_1day_logins) AS logins_1_day_active,
      (stats.accounts.num_7day_logins) AS logins_7_day_active,
      (stats.accounts.num_30day_logins) AS logins_30_day_active,
      (stats.drive.num_30day_active_users) AS docs_30_day_active,
      (stats.gmail.num_30day_active_users) AS gmail_30_day_active,
      (stats.gplus.num_30day_active_users) AS gplus_30_day_active,
      (stats.calendar.num_30day_active_users) AS calendar_30_day_active,
    FROM [YOUR_PROJECT_ID:EXPORT_DATASET.usage] stats
    WHERE TRUE
      AND _PARTITIONTIME = YOUR_TIMESTAMP_PARAMETER
      AND stats.record_type = 'customer'
    ORDER BY
  1 ASC ) customer_usage
  LEFT JOIN
  (
    SELECT
      data.date AS date,
      SUM(data.active_users) AS active_users,
      SUM(data.users_adopted_drive) AS users_adopted_drive,
    FROM
      [YOUR_PROJECT_ID:adoption.drive_adoption_per_day_per_ou] data
    WHERE TRUE
      AND _PARTITIONTIME = YOUR_TIMESTAMP_PARAMETER
    GROUP BY
      date
  ) drive_adoption
  ON drive_adoption.date = customer_usage.date
  LEFT JOIN
  (
    SELECT
    date, SUM(editor_users) as editor_users, SUM(active_users) as active_users,
    FROM
      [YOUR_PROJECT_ID:adoption.editor_adoption_per_day_per_ou] data
    WHERE TRUE
      AND _PARTITIONTIME = YOUR_TIMESTAMP_PARAMETER
    GROUP BY date
  ) editor_adoption
  ON editor_adoption.date = customer_usage.date
  LEFT JOIN
  (SELECT
    date,
    EXACT_COUNT_DISTINCT(email) AS count
  FROM
    [YOUR_PROJECT_ID:users.active_users_with_ou_per_day]
  WHERE date is not null
    AND _PARTITIONTIME = YOUR_TIMESTAMP_PARAMETER
  GROUP BY
    date 
 ) active_users
  ON active_users.date = customer_usage.date
LEFT JOIN (
  SELECT date, EXACT_COUNT_DISTINCT(drive.doc_id) AS total_num_docs FROM (
    SELECT
      STRFTIME_UTC_USEC(time_usec,"%Y-%m-%d") AS date,
      NTH(2, SPLIT(email, '@')) AS domain,
      drive.doc_id
    FROM
      [YOUR_PROJECT_ID:EXPORT_DATASET.activity]
    WHERE
      event_name = 'create'
      AND _PARTITIONTIME >= DATE_ADD(YOUR_TIMESTAMP_PARAMETER, -1, "DAY")
      AND _PARTITIONTIME <= DATE_ADD(YOUR_TIMESTAMP_PARAMETER, 2,"DAY")
      AND DATE(STRFTIME_UTC_USEC(time_usec,"%Y-%m-%d")) = DATE(YOUR_TIMESTAMP_PARAMETER))
  WHERE
    domain IN ( YOUR_DOMAINS )
  GROUP BY
    date ) num_docs
ON
  num_docs.date = customer_usage.date