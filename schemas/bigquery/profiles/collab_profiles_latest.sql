-- collab_profiles_latest
-- Review: 27/02/2017
-- Propose to be deteled 
SELECT
  ou,
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
  [YOUR_PROJECT_ID:profiles.collab_profiles]
WHERE
  _PARTITIONTIME > DATE_ADD(CURRENT_DATE(),-30,"DAY")
GROUP BY 1