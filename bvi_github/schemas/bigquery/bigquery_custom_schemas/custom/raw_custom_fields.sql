-- raw_custom_fields
-- Review: 03/03/2018

SELECT
  LOWER(email) AS email,
  custom_1,
  custom_2,
  custom_3
FROM
  [YOUR_PROJECT_ID:custom.custom_fields]
GROUP BY 1, 2, 3, 4