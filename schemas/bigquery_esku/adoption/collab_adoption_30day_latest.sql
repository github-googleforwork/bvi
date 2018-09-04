-- collab_adoption_30day_latest (view)
-- Review: 2017-12-05

SELECT
  profiles.date AS date,
  profiles.creators_30day as creators_30day,
  profiles.collaborators_30day as collaborators_30day,
  profiles.consumers_30day as consumers_30day,
  profiles.sharers_30day as sharers_30day,
  profiles.idles_30day as idles_30day,
  ROUND(creators_30day/active_users_30day, 2) AS p_creators,
  ROUND(collaborators_30day/active_users_30day, 2) AS p_collaborators,
  ROUND(consumers_30day/active_users_30day, 2) AS p_consumers,
  ROUND(sharers_30day/active_users_30day, 2) AS p_sharers,
  ROUND(idles_30day/active_users_30day, 2) AS p_idles
FROM (
  SELECT
    profiles.date,
    creators_30day,
    collaborators_30day,
    consumers_30day,
    sharers_30day,
    idles_30day,
    adoption.drive_adoption_30day AS drive_users_30day,
    adoption.total_users_30day AS total_users_30day,
    adoption.active_users_30day AS active_users_30day
  FROM (
    SELECT
      date,
      creators_30day,
      collaborators_30day,
      consumers_30day,
      sharers_30day,
      idles_30day
    FROM
      [YOUR_PROJECT_ID:adoption.collab_adoption_30day]
    WHERE
      _PARTITIONTIME = TIMESTAMP((SELECT MAX(date) FROM [YOUR_PROJECT_ID:adoption.adoption_30day]))) profiles
  JOIN
    [YOUR_PROJECT_ID:adoption.adoption_30day] adoption
  ON
    profiles.date = adoption.date)


