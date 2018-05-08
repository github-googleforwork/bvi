--drive_users_1day
--review: 2017-10-30

SELECT
  date AS date,
  email
FROM (
  SELECT  
    DATE(_PARTITIONTIME) AS date, 
    (actor.email) AS email,
    NTH(2, SPLIT(actor.email, '@')) AS domain
  FROM [YOUR_PROJECT_ID:raw_data.audit_log] 
  WHERE 
    id.applicationName = 'drive' 
    AND (actor.email) <> '' 
    AND events.parameters.name = 'primary_event'
    AND _PARTITIONTIME = TIMESTAMP(YOUR_TIMESTAMP_PARAMETER)) drive_usage
WHERE
  domain IN (
  SELECT
    domain
  FROM
    [YOUR_PROJECT_ID:users.users_list_domain] )
GROUP BY 1, 2
