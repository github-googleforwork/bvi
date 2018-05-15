--drive_active_users_30day
--review: 2017-11-22


SELECT
  date,
  SUM(doc_adoption) AS doc_adoption,
  SUM(forms_adoption) AS forms_adoption,
  SUM(slides_adoption) AS slides_adoption,
  SUM(sheets_adoption) AS sheets_adoption,
  SUM(drawing_adoption) AS drawing_adoption,
  SUM(drive_adoption) AS drive_adoption,
  SUM(collaboration_adoption) AS collaboration_adoption
FROM (
  SELECT
    date,
    email,
    IF(SUM(doc_adoption)>0,1,0) AS doc_adoption,
    IF(SUM(forms_adoption)>0,1,0) AS forms_adoption,
    IF(SUM(slides_adoption)>0,1,0) AS slides_adoption,
    IF(SUM(sheets_adoption)>0,1,0) AS sheets_adoption,
    IF(SUM(drawing_adoption)>0,1,0) AS drawing_adoption,
    IF(SUM(drive_adoption)>0,1,0) AS drive_adoption,
    IF(SUM(doc_adoption + forms_adoption + slides_adoption + sheets_adoption + drive_adoption)>0,1,0) AS collaboration_adoption
  FROM (
    SELECT
      *
    FROM (
      SELECT
        DATE(TIMESTAMP(YOUR_TIMESTAMP_PARAMETER)) AS date,
        actor.email AS email,
        NTH(2, SPLIT(actor.email, '@')) AS domain,
        IF(events.parameters.name = "doc_type" and events.parameters.value = "document", 1, 0) AS doc_adoption,
        IF(events.parameters.name = "doc_type" and events.parameters.value = "form", 1, 0) AS forms_adoption,
        IF(events.parameters.name = "doc_type" and events.parameters.value = "presentation", 1, 0) AS slides_adoption,
        IF(events.parameters.name = "doc_type" and events.parameters.value = "spreadsheet", 1, 0) AS sheets_adoption,
        IF(events.parameters.name = "doc_type" and events.parameters.value = "drawing", 1, 0) AS drawing_adoption,
        IF(id.applicationName = "drive", 1, 0) AS drive_adoption,
      FROM
        [YOUR_PROJECT_ID:raw_data.audit_log]
      WHERE
        _PARTITIONTIME >= DATE_ADD(TIMESTAMP(YOUR_TIMESTAMP_PARAMETER), -30, "DAY")
        AND _PARTITIONTIME < DATE_ADD(TIMESTAMP(YOUR_TIMESTAMP_PARAMETER),1,"DAY")
        AND actor.email IS NOT NULL
        AND actor.email <> '' )
    WHERE
      domain IN (
      SELECT
        domain
      FROM
        [YOUR_PROJECT_ID:users.users_list_domain] ) )
  GROUP BY
    1,
    2)
GROUP BY
  1