-- collab_profiles_30day
-- Review: 2018/03/23
SELECT
  date,
  email,
  IF(created > 0, 1, 0) AS is_creator,
  IF(edited > 0, 1, 0) AS is_collaborator,
  IF(consumed > 0, 1, 0) AS is_consumer,
  IF(changed_acl_editors + changed_document_access_scope
    + changed_document_visibility + changed_user_access + team_drive_membership_changed > 0, 1, 0) AS is_sharer
FROM (
  SELECT
    events.date AS date,
    events.actor_email AS email,
    MAX(IF(events.event_name IN ('create', 'upload'), 1, 0)) AS created,
    MAX(IF(events.event_name = 'edit' AND events.owner != events.actor_email, 1, 0)) AS edited,
    MAX(IF(events.event_name IN ('view'), 1, 0)) AS consumed,
    MAX(IF(events.event_name = 'change_acl_editors'
        AND ((visibility_level.public_level > old_visibility_level.public_level)
          OR (events.visibility_change = 'external') ), 1, 0)) AS changed_acl_editors,
    MAX(IF(events.event_name = 'change_document_access_scope'
        AND (visibility_level.public_level > old_visibility_level.public_level), 1, 0)) AS changed_document_access_scope,
    MAX(IF(events.event_name = 'change_document_visibility'
        AND ((visibility_level.public_level > old_visibility_level.public_level)
          OR (events.visibility_change = 'external')
          OR (new_value_visibility_level.public_level > old_value_visibility_level.public_level) ), 1, 0)) AS changed_document_visibility,
    MAX(IF(events.event_name = 'change_user_access'
        AND (visibility_level.public_level > old_visibility_level.public_level), 1, 0)) AS changed_user_access,
    MAX(IF(events.event_name = 'team_drive_membership_change'
        AND (events.membership_change_type IN ('add_to_team_drive',
            're_share')), 1, 0)) AS team_drive_membership_changed,
  FROM (
    SELECT
      date,
      id,
      actor_email,
      event_name,
      GROUP_CONCAT(owner) AS owner,
      GROUP_CONCAT(old_visibility) AS old_visibility,
      GROUP_CONCAT(visibility) AS visibility,
      GROUP_CONCAT(visibility_change) AS visibility_change,
      GROUP_CONCAT(old_value) AS old_value,
      GROUP_CONCAT(new_value) AS new_value,
      GROUP_CONCAT(target_user) AS target_user,
      GROUP_CONCAT(membership_change_type) AS membership_change_type,
    FROM (
      SELECT
        DATE(YOUR_TIMESTAMP_PARAMETER) AS date,
        id,
        email AS actor_email,
        event_name,
        IF(parameter_name='owner', parameter_value, NULL) AS owner,
        IF(parameter_name='old_visibility', parameter_value, NULL) AS old_visibility,
        IF(parameter_name='visibility', parameter_value, NULL) AS visibility,
        IF(parameter_name='visibility_change', parameter_value, NULL) AS visibility_change,
        IF(parameter_name='old_value', parameter_value, NULL) AS old_value,
        IF(parameter_name='new_value', parameter_value, NULL) AS new_value,
        IF(parameter_name='target_user', parameter_value, NULL) AS target_user,
        IF(parameter_name='membership_change_type', parameter_value, NULL) AS membership_change_type
      FROM
        [YOUR_PROJECT_ID:raw_data.audit_log_profilable_events]
      WHERE
        _PARTITIONTIME >= DATE_ADD(YOUR_TIMESTAMP_PARAMETER, -30, "DAY")
        AND _PARTITIONTIME < DATE_ADD(YOUR_TIMESTAMP_PARAMETER,1,"DAY")
        AND domain IN (
            SELECT
              domain
            FROM
              [YOUR_PROJECT_ID:users.users_list_domain])
        AND event_name IN ('create', 'upload', 'edit', 'view', 'change_acl_editors', 'change_document_access_scope',
          'change_document_visibility', 'change_user_access', 'team_drive_membership_change')
      GROUP BY 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12 )
      GROUP BY 1, 2, 3, 4 ) events
  LEFT JOIN
    [YOUR_PROJECT_ID:adoption.visibility_level] old_visibility_level
  ON
    old_visibility_level.visibility = events.old_visibility
  LEFT JOIN
    [YOUR_PROJECT_ID:adoption.visibility_level] visibility_level
  ON
    visibility_level.visibility = events.visibility
  LEFT JOIN
    [YOUR_PROJECT_ID:adoption.visibility_level] old_value_visibility_level
  ON
    old_value_visibility_level.visibility = events.old_value
  LEFT JOIN
    [YOUR_PROJECT_ID:adoption.visibility_level] new_value_visibility_level
  ON
    new_value_visibility_level.visibility = events.new_value
  GROUP BY
    1,
    2 )