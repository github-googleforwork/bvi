-- users_ou_list
-- Review: 16/06/2017
SELECT
  date, lower(primaryEmail) as email, orgUnitPath as ou
FROM
  [YOUR_PROJECT_ID:raw_data.users_list_date]
WHERE 
  _PARTITIONTIME = YOUR_TIMESTAMP_PARAMETER
GROUP BY 1, 2, 3