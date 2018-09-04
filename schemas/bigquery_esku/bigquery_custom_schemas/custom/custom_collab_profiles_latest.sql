-- CUSTOM custom_collab_profiles_latest (view)
-- Review: 25/01/2018

SELECT
  ou,
  custom_1,
  custom_2,
  custom_3,
  SUM(readers) AS readers,
  SUM(creators) AS creators,
  SUM(collaborators) AS collaborators,
  SUM(sharers) AS sharers,
  SUM(anyprofile) AS anyprofile,
  SUM(active) AS active,
  SUM(idles) AS idles,
  ROUND(SUM(readers)/SUM(active), 2) AS P_readers,
  ROUND(SUM(creators)/SUM(active), 2) AS P_creators,
  ROUND(SUM(collaborators)/SUM(active), 2) AS P_collaborators,
  ROUND(SUM(sharers)/SUM(active), 2) AS P_sharers,
  ROUND(SUM(idles)/SUM(active), 2) AS P_idles
FROM
  [YOUR_PROJECT_ID:custom.custom_collab_profiles]
WHERE
  _PARTITIONTIME >= DATE_ADD((SELECT MAX(date) FROM [YOUR_PROJECT_ID:adoption.adoption_30day]),-30,"DAY")
GROUP BY 1,2,3,4
