-- CUSTOM custom_collab_profiles
-- Review: 25/01/2018

SELECT
  data.date AS date,
  IFNULL(data.ou, 'undefined') AS ou,
  IFNULL(data.custom_1, 'undefined') AS custom_1,
  IFNULL(data.custom_2, 'undefined') AS custom_2,
  IFNULL(data.custom_3, 'undefined') AS custom_3,
  IFNULL( INTEGER(SUM(readers)), 0 ) AS readers,
  IFNULL( INTEGER(SUM(creators)), 0 ) AS creators,
  IFNULL( INTEGER(SUM(collaborators)), 0 ) AS collaborators,
  IFNULL( INTEGER(SUM(sharers)), 0 ) AS sharers,
  IFNULL( INTEGER(SUM(anyprofile)), 0 ) AS anyprofile,
  IFNULL( INTEGER(users.count), 0 ) AS active,
  IFNULL( INTEGER(users_total.users), 0 ) AS total,
  (IFNULL( INTEGER(users.count), 0 ) - IFNULL( INTEGER(SUM(anyprofile)), 0 )) AS idles
FROM (
  SELECT
    date,
    ou,
    IFNULL(custom_1, 'undefined') AS custom_1,
    IFNULL(custom_2, 'undefined') AS custom_2,
    IFNULL(custom_3, 'undefined') AS custom_3,
    readers,
    collaborators,
    sharers,
    creators,
    anyprofile
  FROM (
    SELECT
      profiles.date AS date,
      profiles.ou AS ou,
      profiles.custom_1 AS custom_1,
      profiles.custom_2 AS custom_2,
      profiles.custom_3 AS custom_3,
      EXACT_COUNT_DISTINCT(email) AS readers,
    FROM
      [YOUR_PROJECT_ID:custom.custom_profiles_any_per_ou_last_N_days] profiles
    WHERE profiles.is_consumer > 0
    GROUP BY 1, 2, 3, 4, 5),
    (
    SELECT
      profiles.date AS date,
      profiles.ou AS ou,
      profiles.custom_1 AS custom_1,
      profiles.custom_2 AS custom_2,
      profiles.custom_3 AS custom_3,
      EXACT_COUNT_DISTINCT(email) AS collaborators,
    FROM
      [YOUR_PROJECT_ID:custom.custom_profiles_any_per_ou_last_N_days] profiles
    WHERE profiles.is_collaborator > 0
    GROUP BY 1, 2, 3, 4, 5),
    (
    SELECT
      profiles.date AS date,
      profiles.ou AS ou,
      profiles.custom_1 AS custom_1,
      profiles.custom_2 AS custom_2,
      profiles.custom_3 AS custom_3,
      EXACT_COUNT_DISTINCT(email) AS sharers,
    FROM
      [YOUR_PROJECT_ID:custom.custom_profiles_any_per_ou_last_N_days] profiles
    WHERE profiles.is_sharer > 0
    GROUP BY 1, 2, 3, 4, 5),
    (
    SELECT
      profiles.date AS date,
      profiles.ou AS ou,
      profiles.custom_1 AS custom_1,
      profiles.custom_2 AS custom_2,
      profiles.custom_3 AS custom_3,
      EXACT_COUNT_DISTINCT(email) AS creators,
    FROM
      [YOUR_PROJECT_ID:custom.custom_profiles_any_per_ou_last_N_days] profiles
    WHERE profiles.is_creator > 0
    GROUP BY 1, 2, 3, 4, 5),
    (
    SELECT
      profiles.date AS date,
      profiles.ou AS ou,
      profiles.custom_1 AS custom_1,
      profiles.custom_2 AS custom_2,
      profiles.custom_3 AS custom_3,
      EXACT_COUNT_DISTINCT(email) AS anyprofile,
    FROM
      [YOUR_PROJECT_ID:custom.custom_profiles_any_per_ou_last_N_days] profiles
    WHERE ( profiles.is_consumer + profiles.is_creator + profiles.is_collaborator + profiles.is_sharer) > 0
    GROUP BY 1, 2, 3, 4, 5),) data
INNER JOIN (
  SELECT
    ou,
    custom_1,
    custom_2,
    custom_3,
    count
  FROM
    [YOUR_PROJECT_ID:custom.custom_active_users_30da_per_ou]
    GROUP BY 1, 2, 3, 4, 5) users
ON
  data.ou = users.ou
  AND data.custom_1 = users.custom_1
  AND data.custom_2 = users.custom_2
  AND data.custom_3 = users.custom_3
INNER JOIN (
  SELECT
    ou,
    IFNULL(custom.custom_1, 'undefined') AS custom_1,
    IFNULL(custom.custom_2, 'undefined') AS custom_2,
    IFNULL(custom.custom_3, 'undefined') AS custom_3,
    EXACT_COUNT_DISTINCT(users_ou_list.email) AS users
  FROM
    [YOUR_PROJECT_ID:users.users_ou_list] users_ou_list
  LEFT JOIN
    (SELECT email, custom_1, custom_2, custom_3, FROM [YOUR_PROJECT_ID:custom.raw_custom_fields] GROUP BY 1,2,3,4) custom
  ON
    users_ou_list.email = custom.email
  WHERE
    users_ou_list._PARTITIONTIME = YOUR_TIMESTAMP_PARAMETER
  GROUP BY 1,2,3,4 ) users_total
ON
  data.ou = users_total.ou
  AND data.custom_1 = users_total.custom_1
  AND data.custom_2 = users_total.custom_2
  AND data.custom_3 = users_total.custom_3
GROUP BY 1, 2, 3, 4, 5, 11, 12, users.count