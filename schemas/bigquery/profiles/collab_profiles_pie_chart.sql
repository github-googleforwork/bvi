-- collab_profiles_pie_chart (view)
-- Review: 28/02/2017
-- Propose to be deteled 
SELECT
  CURRENT_DATE() AS date,
  type,
  INTEGER(number) AS count,
  number2 as P_count
FROM (
  SELECT
    'readers' AS type,
    SUM(INTEGER(readers)) AS number,
    ROUND(SUM(readers)/SUM(active),2) AS number2
  FROM
    [YOUR_PROJECT_ID:profiles.collab_profiles] profiles
  WHERE
    _PARTITIONTIME > DATE_ADD(CURRENT_DATE(),-30,"DAY")
  GROUP BY 1) readers_data,
  (
  SELECT
    'non_readers' AS type,
    SUM(INTEGER(active - readers)) AS number,
    ROUND(SUM(active - readers)/SUM(active),2) AS number2
  FROM
    [YOUR_PROJECT_ID:profiles.collab_profiles] profiles
  WHERE
    _PARTITIONTIME > DATE_ADD(CURRENT_DATE(),-30,"DAY")
  GROUP BY 1) non_readers_data,
    (
  SELECT
    'creators' AS type,
    SUM(INTEGER(creators)) AS number,
    ROUND(SUM(creators)/SUM(active),2) AS number2
  FROM
    [YOUR_PROJECT_ID:profiles.collab_profiles] profiles
  WHERE
    _PARTITIONTIME > DATE_ADD(CURRENT_DATE(),-30,"DAY")
  GROUP BY 1) creators_data,
    (
  SELECT
    'non_creators' AS type,
    SUM(INTEGER(active - creators)) AS number,
    ROUND(SUM(active - creators)/SUM(active),2) AS number2
  FROM
    [YOUR_PROJECT_ID:profiles.collab_profiles] profiles
  WHERE
    _PARTITIONTIME > DATE_ADD(CURRENT_DATE(),-30,"DAY")
  GROUP BY 1) non_creators_data,
    (
  SELECT
    'collaborators' AS type,
    SUM(INTEGER(collaborators)) AS number,
    ROUND(SUM(collaborators)/SUM(active),2) AS number2
  FROM
    [YOUR_PROJECT_ID:profiles.collab_profiles] profiles
  WHERE
    _PARTITIONTIME > DATE_ADD(CURRENT_DATE(),-30,"DAY")
  GROUP BY 1) collaborators_data,
    (
  SELECT
    'non_collaborators' AS type,
    SUM(INTEGER(active - collaborators)) AS number,
    ROUND(SUM(active - collaborators)/SUM(active),2) AS number2
  FROM
    [YOUR_PROJECT_ID:profiles.collab_profiles] profiles
  WHERE
    _PARTITIONTIME > DATE_ADD(CURRENT_DATE(),-30,"DAY")
  GROUP BY 1) non_collaborators_data,
    (
  SELECT
    'sharers' AS type,
    SUM(INTEGER(sharers)) AS number,
    ROUND(SUM(sharers)/SUM(active),2) AS number2
  FROM
    [YOUR_PROJECT_ID:profiles.collab_profiles] profiles
  WHERE
    _PARTITIONTIME > DATE_ADD(CURRENT_DATE(),-30,"DAY")
  GROUP BY 1) sharers_data,
    (
  SELECT
    'non_sharers' AS type,
    SUM(INTEGER(active - sharers)) AS number,
    ROUND(SUM(active - sharers)/SUM(active),2) AS number2
  FROM
    [YOUR_PROJECT_ID:profiles.collab_profiles] profiles
  WHERE
    _PARTITIONTIME > DATE_ADD(CURRENT_DATE(),-30,"DAY")
  GROUP BY 1) non_sharers_data,
    (
  SELECT
    'any' AS type,
    SUM(INTEGER(anyprofile)) AS number,
    ROUND(SUM(anyprofile)/SUM(active),2) AS number2
  FROM
    [YOUR_PROJECT_ID:profiles.collab_profiles] profiles
  WHERE
    _PARTITIONTIME > DATE_ADD(CURRENT_DATE(),-30,"DAY")
  GROUP BY 1) any_data,
    (
  SELECT
    'non_any' AS type,
    SUM(INTEGER(active - anyprofile)) AS number,
    ROUND(SUM(active - anyprofile)/SUM(active),2) AS number2
  FROM
    [YOUR_PROJECT_ID:profiles.collab_profiles] profiles
  WHERE
    _PARTITIONTIME > DATE_ADD(CURRENT_DATE(),-30,"DAY")
  GROUP BY 1) non_any_data,
  (
  SELECT
    'idles' AS type,
    SUM(INTEGER(idles)) AS number,
    ROUND(SUM(idles)/SUM(active),2) AS number2
  FROM
    [YOUR_PROJECT_ID:profiles.collab_profiles] profiles
  WHERE
    _PARTITIONTIME > DATE_ADD(CURRENT_DATE(),-30,"DAY")
  GROUP BY 1) idles_data,
  (
  SELECT
    'non_idles' AS type,
    SUM(INTEGER(active - idles)) AS number,
    ROUND(SUM(active - idles)/SUM(active),2) AS number2
  FROM
    [YOUR_PROJECT_ID:profiles.collab_profiles] profiles
  WHERE
    _PARTITIONTIME > DATE_ADD(CURRENT_DATE(),-30,"DAY")
  GROUP BY 1) non_idles_data