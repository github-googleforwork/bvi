-- collab_adoption_30day
-- Review: 2018/03/24


SELECT
  profiles.date AS date,
  adoption.active_users_30day AS active_users_30day,
  SUM (is_creator) AS creators_30day,
  SUM (is_collaborator) AS collaborators_30day,
  SUM (is_consumer) AS consumers_30day,
  SUM (is_sharer) AS sharers_30day,
  active_users_30day - SUM(CASE
      WHEN is_creator = 1 OR is_collaborator = 1 OR is_consumer = 1 OR is_sharer = 1 THEN 1
      ELSE 0 END) AS idles_30day
FROM
  [YOUR_PROJECT_ID:profiles.collab_profiles_30day] profiles
JOIN
  [YOUR_PROJECT_ID:adoption.adoption_30day] adoption
ON
  profiles.date = adoption.date
WHERE
  profiles._PARTITIONTIME = TIMESTAMP(YOUR_TIMESTAMP_PARAMETER)
GROUP BY 1, 2