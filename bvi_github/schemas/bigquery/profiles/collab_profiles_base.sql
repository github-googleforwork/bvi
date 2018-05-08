-- collab_profiles_base
-- Review: 20/02/2017
-- Propose to be deteled 
SELECT
  date,
  type,
  INTEGER(number) as count
FROM (
  SELECT
    date,
    'readers' AS type,
    INTEGER(EXACT_COUNT_DISTINCT( email )) AS number
  FROM
    [YOUR_PROJECT_ID:profiles.profiles_any_per_day_no_ou] profiles
  WHERE
    _PARTITIONTIME = YOUR_TIMESTAMP_PARAMETER
    AND is_consumer > 0
  GROUP BY
    1) readers_data,
  (
  SELECT
    date,
    'creators' AS type,
    INTEGER(EXACT_COUNT_DISTINCT( email )) AS number
  FROM
    [YOUR_PROJECT_ID:profiles.profiles_any_per_day_no_ou] profiles
  WHERE
    _PARTITIONTIME = YOUR_TIMESTAMP_PARAMETER
    AND is_creator > 0
  GROUP BY
    1) creators_data,
  (
  SELECT
    date,
    'collaborators' AS type,
    INTEGER(EXACT_COUNT_DISTINCT( email )) AS number
  FROM
    [YOUR_PROJECT_ID:profiles.profiles_any_per_day_no_ou] profiles
  WHERE
    _PARTITIONTIME = YOUR_TIMESTAMP_PARAMETER AND is_collaborator > 0
  GROUP BY
    1) collaborators_data,
  (
  SELECT
    date,
    'sharers' AS type,
    INTEGER(EXACT_COUNT_DISTINCT( email )) AS number
  FROM
    [YOUR_PROJECT_ID:profiles.profiles_any_per_day_no_ou] profiles
  WHERE
    _PARTITIONTIME = YOUR_TIMESTAMP_PARAMETER  AND is_sharer > 0
  GROUP BY
    1) sharers_data,
  (
  SELECT
    date,
    'any' AS type,
    INTEGER(EXACT_COUNT_DISTINCT( email )) AS number
  FROM
    [YOUR_PROJECT_ID:profiles.profiles_any_per_day_no_ou] profiles
  WHERE
    _PARTITIONTIME = YOUR_TIMESTAMP_PARAMETER
  GROUP BY
    1) sharers_data