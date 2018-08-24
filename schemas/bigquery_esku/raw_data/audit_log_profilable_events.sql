-- audit_log_profilable_events
-- Review: 2018/03/23
SELECT
  *,
  NTH(2, SPLIT(email, '@')) AS domain
FROM (
  SELECT
    STRFTIME_UTC_USEC(time_usec,"%Y-%m-%d") AS date,
    drive.doc_id AS id,
    email,
    event_type,
    event_name,
    drive.owner AS owner,
    drive.visibility_change AS visibility_change,
    drive.old_visibility AS old_visibility,
    drive.visibility AS visibility,
    drive.target_user AS target_user,
    drive.membership_change_type AS membership_change_type,
    GROUP_CONCAT(drive.old_value) AS old_value,
    GROUP_CONCAT(drive.new_value) AS new_value
  FROM
    [YOUR_PROJECT_ID:EXPORT_DATASET.activity]
  WHERE
    TRUE
    AND _PARTITIONTIME >= DATE_ADD(YOUR_TIMESTAMP_PARAMETER, -1, "DAY")
    AND _PARTITIONTIME <= DATE_ADD(YOUR_TIMESTAMP_PARAMETER, 2,"DAY")
    AND DATE(STRFTIME_UTC_USEC(time_usec,"%Y-%m-%d")) = DATE(YOUR_TIMESTAMP_PARAMETER)
    AND record_type = 'drive'
    AND event_type IS NOT NULL
    AND event_name IN ('create', 'upload', 'edit', 'rename', 'move', 'add_to_folder', 'view',
      'change_acl_editors', 'change_document_access_scope', 'change_document_visibility',
      'change_user_access', 'team_drive_membership_change')
    AND email IS NOT NULL
    AND email <> ""
  GROUP BY 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11 )