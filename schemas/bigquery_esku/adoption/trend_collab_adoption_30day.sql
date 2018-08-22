-- trend_collab_adoption_30day (view)

SELECT
  date AS date,
  creators_30day,
  collaborators_30day,
  consumers_30day,
  sharers_30day,
  idles_30day,
  active_users_30day,
  ROUND(creators_30day/active_users_30day, 2) AS p_creators_30day,
  ROUND(collaborators_30day/active_users_30day, 2) AS p_collaborators_30day,
  ROUND(consumers_30day/active_users_30day, 2) AS p_consumers_30day,
  ROUND(sharers_30day/active_users_30day, 2) AS p_sharers_30day,
  ROUND(idles_30day/active_users_30day, 2) AS p_idles_30day,
FROM
  [YOUR_PROJECT_ID:adoption.collab_adoption_30day]
WHERE
  date IN (
  SELECT
    MAX(date)
  FROM (
    SELECT
      DATE(date) AS date,
      MONTH(DATE(date)) AS month
    FROM
      [YOUR_PROJECT_ID:adoption.collab_adoption_30day]
    WHERE
      date >= DATE(DATE_ADD(TIMESTAMP(CURRENT_DATE()), -6, "MONTH"))
      AND DAY(DATE(date)) <= DAY(DATE_ADD(TIMESTAMP(CURRENT_DATE()), -4, "DAY")) )
  GROUP BY
    month)