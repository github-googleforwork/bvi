-- audit_log_profilable_events
-- Review: 27/09/2017
SELECT
  date,
  id.uniqueQualifier AS id, 
  actor.email AS email,
  domain,
  events.type AS event_type,
  events.name AS event_name,
  events.parameters.name AS parameter_name,
  events.parameters.value AS parameter_value
FROM (
      SELECT
        STRFTIME_UTC_USEC(id.time,"%Y-%m-%d") AS date,
        id.uniqueQualifier,
        actor.email,
        NTH(2, SPLIT(actor.email, '@')) AS domain,
        events.type,
        events.name,
        events.parameters.name,
        events.parameters.value
      FROM
        [YOUR_PROJECT_ID:raw_data.audit_log]
      WHERE TRUE
        AND _PARTITIONTIME = TIMESTAMP(YOUR_TIMESTAMP_PARAMETER)
        AND id.applicationName = 'drive'
        AND events.type IS NOT NULL
        AND events.name IN ('create', 'upload', 'edit', 'rename', 'move', 'add_to_folder', 'view', 'change_acl_editors',
    'change_document_access_scope', 'change_document_visibility', 'change_user_access', 'team_drive_membership_change')
        AND actor.email IS NOT NULL
        AND actor.email <> "" 
    )
GROUP BY 1, 2, 3, 4, 5, 6, 7, 8