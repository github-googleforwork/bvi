--drive_active_users_30day

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
        email AS email,
        NTH(2, SPLIT(email, '@')) AS domain,
        drive.doc_type,
        IF(drive.doc_type = "document", 1, 0) AS doc_adoption,
        IF(drive.doc_type = "form", 1, 0) AS forms_adoption,
        IF(drive.doc_type = "presentation", 1, 0) AS slides_adoption,
        IF(drive.doc_type = "spreadsheet", 1, 0) AS sheets_adoption,
        IF(drive.doc_type = "drawing", 1, 0) AS drawing_adoption,
        IF(record_type = "drive", 1, 0) AS drive_adoption
      FROM
        [YOUR_PROJECT_ID:Reports.activity]
      WHERE
        TRUE
        AND _PARTITIONTIME >= DATE_ADD(YOUR_TIMESTAMP_PARAMETER, -31, "DAY")
        AND _PARTITIONTIME < DATE_ADD(TIMESTAMP(YOUR_TIMESTAMP_PARAMETER),2,"DAY")
        AND TIMESTAMP(STRFTIME_UTC_USEC(time_usec,"%Y-%m-%d")) >= DATE_ADD(YOUR_TIMESTAMP_PARAMETER,-30,"DAY")
        AND TIMESTAMP(STRFTIME_UTC_USEC(time_usec,"%Y-%m-%d")) < DATE_ADD(YOUR_TIMESTAMP_PARAMETER,1,"DAY")
        AND email IS NOT NULL
        AND email <> '' )
    WHERE
      domain IN ( YOUR_DOMAINS ))
  GROUP BY
    1,
    2)
GROUP BY
  1