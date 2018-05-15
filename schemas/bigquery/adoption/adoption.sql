-- adoption
-- reviewed: 23/02/2017
SELECT
  customer_usage.date as date,
  customer_usage.num_users AS num_total_users,
  customer_usage.num_suspended_users AS num_suspended_users,
  ( customer_usage.num_users - customer_usage.num_suspended_users ) AS num_non_suspended_users,
  active_users.count as active_users_1d,
  customer_usage.logins_30_day_active as active_users_30_days,
  ( customer_usage.docs_30_day_active ) AS docs_adoption,
  ( customer_usage.gmail_30_day_active ) AS gmail_adoption,
  ( customer_usage.gplus_30_day_active ) AS gplus_adoption,
  ( customer_usage.calendar_30_day_active ) AS calendar_adoption,
  num_docs.total_num_docs AS total_num_docs,
  drive_adoption.active_users as active_users_drive,
  drive_adoption.users_adopted_drive as users_adopted_drive,
  editor_adoption.active_users as active_users_editor,
  editor_adoption.editor_users as editor_adoption,
FROM
  (
    SELECT
      stats.date AS date,
      (stats.num_users) AS num_users,
      (stats.num_suspended_users) AS num_suspended_users,
      (stats.num_1day_logins) AS logins_1_day_active,
      (stats.num_7day_logins) AS logins_7_day_active,
      (stats.num_30day_logins) AS logins_30_day_active,
      (stats.docs_30da) AS docs_30_day_active,
      (stats.gmail_30da) AS gmail_30_day_active,
      (stats.gplus_30da) AS gplus_30_day_active,
      (stats.calendar_30da) AS calendar_30_day_active,
     --Not a source of truth
     --(stats.num_docs_customer) AS total_num_docs,
    FROM [YOUR_PROJECT_ID:adoption.customer_usage_date_summary] stats
    WHERE TRUE
  --    AND TIMESTAMP(date) > DATE_ADD(CURRENT_DATE(),-30,"DAY")
      AND _PARTITIONTIME = YOUR_TIMESTAMP_PARAMETER
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
  SELECT
    DATE(id.time) AS date,
    EXACT_COUNT_DISTINCT(id.uniqueQualifier) AS total_num_docs
  FROM
    [YOUR_PROJECT_ID:raw_data.audit_log]
  WHERE
    events.name = 'create'
    AND _PARTITIONTIME = YOUR_TIMESTAMP_PARAMETER
  GROUP BY
    date ) num_docs
ON
  num_docs.date = customer_usage.date
