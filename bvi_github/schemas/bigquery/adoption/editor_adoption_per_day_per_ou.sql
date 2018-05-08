-- editor_adoption_per_day_per_ou
SELECT
  active_users.date AS date,
  active_users.ou AS ou,
  active_users.count AS active_users,
  IFNULL(INTEGER(collaboration_editor_adoption.count), 0) as editor_users,
FROM
  (
    SELECT
      date AS date,
      ou AS ou,
      EXACT_COUNT_DISTINCT(email) AS count
    FROM [YOUR_PROJECT_ID:users.active_users_with_ou_per_day]
    GROUP BY date, ou
    ORDER BY 1
  ) active_users
  LEFT JOIN
  (
    SELECT
      date,
      ou,
      EXACT_COUNT_DISTINCT(email) AS count
    FROM
    (
      SELECT date, email, ou
      FROM
      [YOUR_PROJECT_ID:adoption.audit_log_drive_adoption_per_day],
      (
          SELECT
            mdate as date,
            audit.email as email,
            IFNULL(users.ou, 'NA') as ou
          FROM
          (
            SELECT
             STRFTIME_UTC_USEC(id.time,"%Y-%m-%d") AS mdate,
              actor.email AS email,
              IFNULL(users.ou, 'NA') AS ou,
              events.parameters.value as product,
              count(*) as count
            FROM
              [YOUR_PROJECT_ID:raw_data.audit_log] audit
            JOIN (
              SELECT
                users_ou_list.email email,
                IFNULL(users_ou_list.ou, 'NA') AS ou
              FROM
                [YOUR_PROJECT_ID:users.users_ou_list] users_ou_list
              WHERE
                TRUE
                AND users_ou_list._PARTITIONTIME > DATE_ADD(YOUR_TIMESTAMP_PARAMETER,-10,"DAY")
              GROUP BY
                1,
                2) users
            ON
              users.email = audit.actor.email
            WHERE
              TRUE
              AND id.applicationName = 'drive'
              AND events.parameters.name = 'doc_type'
              AND id.uniqueQualifier IN (
                SELECT
                  id.uniqueQualifier
                FROM
                  [YOUR_PROJECT_ID:raw_data.audit_log]
                WHERE
                  true
                  -- AND TIMESTAMP( STRFTIME_UTC_USEC(id.time,"%Y-%m-%d") ) > DATE_ADD(CURRENT_DATE(),-30,"DAY")
                  AND _PARTITIONTIME > DATE_ADD(YOUR_TIMESTAMP_PARAMETER,-10,"DAY")
                  AND id.applicationName = 'drive'
                  AND events.type IS NOT NULL
                  AND events.parameters.name = 'primary_event'
                  AND events.parameters.boolValue
                  AND actor.email IS NOT NULL
                  AND actor.email <> ""
                GROUP BY 1
              )
            GROUP BY mdate, email, ou, product
            ORDER BY mdate, email,
          ) audit
          LEFT JOIN (
            SELECT email, ou
            FROM [YOUR_PROJECT_ID:users.users_ou_list]
            GROUP BY email, ou
          ) users
          ON audit.email = users.email
          WHERE product in ('presentation', 'document', 'spreadsheet', 'form')
          GROUP BY date, email, ou
      )
    )
    GROUP BY 1,2
  ) collaboration_editor_adoption
  ON collaboration_editor_adoption.date = active_users.date
  AND collaboration_editor_adoption.ou = active_users.ou
WHERE
  TIMESTAMP(active_users.date) = YOUR_TIMESTAMP_PARAMETER