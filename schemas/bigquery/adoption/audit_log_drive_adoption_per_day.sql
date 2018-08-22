-- audit_log_drive_adoption_per_day
-- Review: 20/2/2017
SELECT
  date as date,
  email,
  COUNT(*) AS count
FROM (
  SELECT
    date as date,
    domain AS domain,
    email AS email
  FROM
    [YOUR_PROJECT_ID:raw_data.audit_log_profilable_events]
  WHERE
    true
    AND event_name IN ('create', 'upload', 'edit', 'view',
    'rename', 'move', 'add_to_folder', 'remove_from_folder', 
    'trash', 'delete', 'untrash', 'download', 'preview', 'print', 
    'change_acl_editors', 'change_document_access_scope', 
    'change_document_visibility', 'change_user_access')
    AND email IS NOT NULL
    AND email <> "" 
    AND _PARTITIONTIME = YOUR_TIMESTAMP_PARAMETER)
WHERE
  true
  AND domain IN ( YOUR_DOMAINS )
  AND email IN (
    SELECT
      email
    FROM
      [YOUR_PROJECT_ID:users.active_users_with_ou_per_day]
  )
GROUP BY 1, 2
