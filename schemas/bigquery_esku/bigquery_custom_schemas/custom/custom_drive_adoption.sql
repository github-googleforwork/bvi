-- custom_drive_adoption (view)
-- Review: 22/01/2018

SELECT
  *
FROM
  [YOUR_PROJECT_ID:custom.custom_drive_adoption_per_day_per_ou]
WHERE
  _PARTITIONTIME >= DATE_ADD((SELECT MAX(date) FROM [YOUR_PROJECT_ID:adoption.adoption_30day]),-30,"DAY")
  AND date = (
  SELECT
    MAX(date)
  FROM
    [YOUR_PROJECT_ID:custom.custom_drive_adoption_per_day_per_ou])
