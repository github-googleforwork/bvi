-- drive_adoption (view)
-- Review: 06/04/2017
SELECT
  *
FROM
  [YOUR_PROJECT_ID:adoption.drive_adoption_per_day_per_ou]
WHERE
  _PARTITIONTIME >= DATE_ADD((SELECT MAX(date) FROM [YOUR_PROJECT_ID:adoption.adoption_30day]),-30,"DAY")
  AND date = (
  SELECT
    MAX(date)
  FROM
    [YOUR_PROJECT_ID:adoption.drive_adoption_per_day_per_ou])