-- collab_profiles
-- Review: 16/03/2017
-- Propose to be deteled 
SELECT
  data.date AS date,
  IFNULL(data.ou, 'NA') AS ou,
  IFNULL( INTEGER(SUM(readers)), NULL ) AS readers,
  IFNULL( INTEGER(SUM(creators)), NULL ) AS creators,
  IFNULL( INTEGER(SUM(collaborators)), NULL ) AS collaborators,
  IFNULL( INTEGER(SUM(sharers)), NULL ) AS sharers,
  IFNULL( INTEGER(SUM(anyprofile)), NULL ) AS anyprofile,
  IFNULL( INTEGER(users.count), NULL ) AS active,
  IFNULL( INTEGER(users_total.users), 0 ) AS total,
  (IFNULL( INTEGER(users.count), NULL ) - IFNULL( INTEGER(SUM(anyprofile)), NULL )) AS idles
FROM (
  SELECT
    *
  FROM (
    SELECT
      profiles.date AS date,
      profiles.ou AS ou,
      COUNT(profiles.email) AS readers,
    FROM
      [YOUR_PROJECT_ID:profiles.profiles_any_per_ou_last_N_days] profiles
    WHERE
      _PARTITIONTIME = YOUR_TIMESTAMP_PARAMETER
      AND profiles.is_consumer > 0
    GROUP BY 1, 2),
    (
    SELECT
      profiles.date AS date,
      profiles.ou AS ou,
      COUNT(profiles.email) AS collaborators,
    FROM
      [YOUR_PROJECT_ID:profiles.profiles_any_per_ou_last_N_days] profiles
    WHERE
      _PARTITIONTIME = YOUR_TIMESTAMP_PARAMETER
      AND profiles.is_collaborator > 0
    GROUP BY 1, 2),
    (
    SELECT
      profiles.date AS date,
      profiles.ou AS ou,
      COUNT(profiles.email) AS sharers,
    FROM
      [YOUR_PROJECT_ID:profiles.profiles_any_per_ou_last_N_days] profiles
    WHERE
      _PARTITIONTIME = YOUR_TIMESTAMP_PARAMETER
      AND profiles.is_sharer > 0
    GROUP BY 1, 2),
    (
    SELECT
      profiles.date AS date,
      profiles.ou AS ou,
      COUNT(profiles.email) AS creators,
    FROM
      [YOUR_PROJECT_ID:profiles.profiles_any_per_ou_last_N_days] profiles
    WHERE
      _PARTITIONTIME = YOUR_TIMESTAMP_PARAMETER
      AND profiles.is_creator > 0
    GROUP BY 1, 2),
    (
    SELECT
      profiles.date AS date,
      profiles.ou AS ou,
      COUNT(profiles.email) AS anyprofile,
    FROM
      [YOUR_PROJECT_ID:profiles.profiles_any_per_ou_last_N_days] profiles
    WHERE
      _PARTITIONTIME = YOUR_TIMESTAMP_PARAMETER
      AND ( profiles.is_consumer + profiles.is_creator + profiles.is_collaborator + profiles.is_sharer) > 0
    GROUP BY 1, 2),) data
INNER JOIN (
  SELECT
    ou,
    count
  FROM
    [YOUR_PROJECT_ID:users.active_users_30da_per_ou]
  WHERE
    _PARTITIONTIME = YOUR_TIMESTAMP_PARAMETER
    GROUP BY 1, 2) users
ON
  data.ou = users.ou
INNER JOIN (
  SELECT
    ou,
    COUNT(email) AS users
  FROM
    [YOUR_PROJECT_ID:users.users_ou_list]
  WHERE
    _PARTITIONTIME = YOUR_TIMESTAMP_PARAMETER
  GROUP BY 1 ) users_total
ON
  data.ou = users_total.ou
GROUP BY 1, 2, 8, 9, users.count
