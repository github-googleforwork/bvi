-- CUSTOM custom_profiles_any_per_ou_last_N_days
-- Review: 24/01/2018

SELECT
  profiles_any_per_ou_last_N_days.date as date,
  profiles_any_per_ou_last_N_days.email as email,
  profiles_any_per_ou_last_N_days.is_collaborator as is_collaborator,
  profiles_any_per_ou_last_N_days.is_consumer as is_consumer,
  profiles_any_per_ou_last_N_days.is_creator as is_creator,
  profiles_any_per_ou_last_N_days.is_sharer as is_sharer,
  profiles_any_per_ou_last_N_days.ou as ou,
  custom.custom_1 as custom_1,
  custom.custom_2 as custom_2,
  custom.custom_3 as custom_3
FROM
  [YOUR_PROJECT_ID:profiles.profiles_any_per_ou_last_N_days] profiles_any_per_ou_last_N_days
LEFT JOIN
  (SELECT email, custom_1, custom_2, custom_3, FROM [YOUR_PROJECT_ID:custom.raw_custom_fields] GROUP BY 1,2,3,4) custom
ON
  profiles_any_per_ou_last_N_days.email = custom.email
WHERE
  profiles_any_per_ou_last_N_days._PARTITIONTIME = DATE_ADD(CURRENT_DATE(),-4,"DAY")
