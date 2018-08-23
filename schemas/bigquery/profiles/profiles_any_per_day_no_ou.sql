-- profiles_any_per_day_no_ou
-- Review: 24/08/2017
SELECT
  date AS date,
  email AS email,
  MAX(CASE
      WHEN event_name IN ('create',  'upload') THEN 1
      ELSE 0 END) AS is_creator,
  MAX(CASE
      WHEN (event_name IN ('edit') AND (parameter_name = 'owner') AND (email <> parameter_value)) THEN 1
      ELSE 0 END) AS is_collaborator,
  MAX(CASE
      WHEN event_name IN ('view') THEN 1
      ELSE 0 END) AS is_consumer,
  MAX(CASE
      WHEN (event_name IN ('change_document_visibility') AND (parameter_name = 'visibility_change') AND (parameter_value = 'external')) THEN 1
      WHEN event_name IN ('change_acl_editors',  'change_document_access_scope',  'change_user_access',  'team_drive_membership_change') THEN 1
      ELSE 0 END) AS is_sharer
FROM
  [YOUR_PROJECT_ID:raw_data.audit_log_profilable_events]
WHERE
  TRUE 
  AND _PARTITIONTIME = YOUR_TIMESTAMP_PARAMETER
  AND domain IN ( YOUR_DOMAINS )
  AND event_name IN ('create', 'upload', 'edit', 'view', 'change_acl_editors', 'change_document_access_scope',
    'change_document_visibility', 'change_user_access', 'team_drive_membership_change')
GROUP BY 1, 2
ORDER BY 1