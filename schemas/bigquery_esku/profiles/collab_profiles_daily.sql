-- collab_profiles_daily
-- Review: 24/08/2017
SELECT
  users.date AS date, 
  users.ou AS ou,
  creator,
  collaborator,
  reader, 
  sharer, 
  anyprofile,
  (users.users - (CASE WHEN anyprofile IS NULL THEN 0 ELSE anyprofile END)) AS idle,
  users.users AS total_users
FROM (SELECT 
        date,
        IFNULL( ou, 'NA' ) AS ou,
        SUM(CASE
            WHEN is_creator = 1 THEN 1
            ELSE NULL END) AS creator,
        SUM(CASE
            WHEN is_collaborator = 1 THEN 1
            ELSE NULL END) AS collaborator,
        SUM(CASE
            WHEN is_consumer = 1 THEN 1
            ELSE NULL END) AS reader,
        SUM(CASE
            WHEN is_sharer = 1 THEN 1
            ELSE NULL END) AS sharer,
        SUM(CASE
            WHEN ((is_creator = 1) OR (is_collaborator = 1) OR (is_consumer = 1) OR (is_sharer = 1)) THEN 1
            ELSE NULL END) AS anyprofile
      FROM
        [YOUR_PROJECT_ID:profiles.profiles_any_per_day_per_ou] profiles
      WHERE
        TRUE
        AND _PARTITIONTIME = YOUR_TIMESTAMP_PARAMETER
      GROUP BY 1, 2) profiles
FULL OUTER JOIN EACH (SELECT
        date,
        IFNULL( ou, 'NA' ) AS ou,
        EXACT_COUNT_DISTINCT(email) as users
      FROM
        [YOUR_PROJECT_ID:users.active_users_with_ou_per_day]
      WHERE
        _PARTITIONTIME = YOUR_TIMESTAMP_PARAMETER
      GROUP BY 1, 2) users
ON
  profiles.ou = users.ou