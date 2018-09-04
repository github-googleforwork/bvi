-- editor_adoption_per_day_per_ou
SELECT
  active_users.date AS date,
  active_users.ou AS ou,
  active_users.count AS active_users,
  IFNULL(INTEGER(collaboration_editor_adoption.count), 0) AS editor_users,
FROM (
  SELECT
    date AS date,
    ou AS ou,
    EXACT_COUNT_DISTINCT(email) AS count
  FROM
    [YOUR_PROJECT_ID:users.active_users_with_ou_per_day]
  GROUP BY
    date,
    ou
  ORDER BY
    1 ) active_users
LEFT JOIN (
  SELECT
    date,
    ou,
    EXACT_COUNT_DISTINCT(email) AS count
  FROM (
    SELECT
      date,
      email,
      ou
    FROM
      [YOUR_PROJECT_ID:adoption.audit_log_drive_adoption_per_day],
      (
      SELECT
        mdate AS date,
        audit.email AS email,
        IFNULL(users.ou, 'NA') AS ou
      FROM (
        SELECT
          STRFTIME_UTC_USEC(time_usec,"%Y-%m-%d") AS mdate,
          audit.email AS email,
          IFNULL(users.ou, 'NA') AS ou,
          drive.doc_type AS product,
          COUNT(*) AS count
        FROM
          [YOUR_PROJECT_ID:Reports.activity] audit
        JOIN (
          SELECT
            users_ou_list.email email,
            IFNULL(users_ou_list.ou, 'NA') AS ou
          FROM
            [YOUR_PROJECT_ID:users.users_ou_list] users_ou_list
          WHERE
            TRUE
            AND users_ou_list._PARTITIONTIME > DATE_ADD(YOUR_TIMESTAMP_PARAMETER,-10,"DAY")
            AND users_ou_list._PARTITIONTIME <= TIMESTAMP((SELECT MAX(date) FROM [YOUR_PROJECT_ID:adoption.adoption_30day]))
          GROUP BY
            1,
            2) users
        ON
          users.email = audit.email
        WHERE
          TRUE
          AND record_type = 'drive'
          AND drive.doc_id IN (
          SELECT
            drive.doc_id
          FROM
            [YOUR_PROJECT_ID:Reports.activity]
          WHERE
            TRUE
            AND _PARTITIONTIME >= DATE_ADD(YOUR_TIMESTAMP_PARAMETER, -11, "DAY")
            AND _PARTITIONTIME <= DATE_ADD(YOUR_TIMESTAMP_PARAMETER, -3,"DAY")
            AND TIMESTAMP(STRFTIME_UTC_USEC(time_usec,"%Y-%m-%d")) > DATE_ADD(YOUR_TIMESTAMP_PARAMETER,-10,"DAY")
            AND TIMESTAMP(STRFTIME_UTC_USEC(time_usec,"%Y-%m-%d")) <= DATE_ADD(YOUR_TIMESTAMP_PARAMETER,-4,"DAY")
            AND record_type = 'drive'
            AND event_type IS NOT NULL
            AND drive.primary_event
            AND email IS NOT NULL
            AND email <> ""
          GROUP BY
            1 )
        GROUP BY
          mdate,
          email,
          ou,
          product
        ORDER BY
          mdate,
          email,
          ) audit
      LEFT JOIN (
        SELECT
          email,
          ou
        FROM
          [YOUR_PROJECT_ID:users.users_ou_list]
        GROUP BY
          email,
          ou ) users
      ON
        audit.email = users.email
      WHERE
        product IN ('presentation',
          'document',
          'spreadsheet',
          'form')
      GROUP BY
        date,
        email,
        ou ) )
  GROUP BY
    1,
    2 ) collaboration_editor_adoption
ON
  collaboration_editor_adoption.date = active_users.date
  AND collaboration_editor_adoption.ou = active_users.ou
WHERE
  TIMESTAMP(active_users.date) = YOUR_TIMESTAMP_PARAMETER












