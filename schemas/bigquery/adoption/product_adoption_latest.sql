-- product_adoption_latest (view)
-- Review: 23/02/2017
SELECT
  adoption.date AS date,
  adoption.ou AS ou,
  adoption.active_users_total AS adoption_users,
  users.count AS active_users,
  adoption.document AS users_adopting_documents,
  adoption.spreadsheet AS users_adopting_spreadsheets,
  adoption.presentation AS users_adopting_presentations, 
  adoption.form AS users_adopting_forms,
  adoption.folder AS users_adopting_folders,
  adoption.drawing AS users_adopting_drawings,
  adoption.unknown AS users_adopting_other_files
FROM (
  SELECT
    date,
    ou,
    active_users_total,
    document,
    spreadsheet,
    presentation,
    form, 
    folder,
    drawing,
    unknown
  FROM
    [YOUR_PROJECT_ID:adoption.product_adoption_daily]
  WHERE
    _PARTITIONTIME >= DATE_ADD((SELECT MAX(date) FROM [YOUR_PROJECT_ID:adoption.adoption_30day]),-30,"DAY")
    AND date = (SELECT MAX(date) FROM [YOUR_PROJECT_ID:adoption.product_adoption_daily])
  GROUP BY
      1, 2, 3, 4, 5, 6, 7, 8, 9, 10) adoption
INNER JOIN 
  (
    SELECT
      date, ou, EXACT_COUNT_DISTINCT(email) as count
    FROM
      [YOUR_PROJECT_ID:users.active_users_with_ou_per_day]
    WHERE
      _PARTITIONTIME >= DATE_ADD((SELECT MAX(date) FROM [YOUR_PROJECT_ID:adoption.adoption_30day]),-30,"DAY")
      AND date = (SELECT MAX(date) FROM [YOUR_PROJECT_ID:adoption.product_adoption_daily])
    GROUP BY 1, 2
  ) users
ON
  adoption.ou = users.ou