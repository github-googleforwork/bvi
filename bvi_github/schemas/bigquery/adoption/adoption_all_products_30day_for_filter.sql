-- adoption_all_products_30day_for_filter

SELECT
  *
FROM (
  SELECT
    1 AS index,
    date,
    'Gmail' AS product,
    gmail_adoption_30day AS adoption,
    gmail_adoption_30day / active_users_30day AS p_adoption
  FROM
    [YOUR_PROJECT_ID:adoption.adoption_all_products_30day] WHERE date = DATE(TIMESTAMP(YOUR_TIMESTAMP_PARAMETER))),
  (
  SELECT
    2 AS index,
    date,
    'Calendar' AS product,
    calendar_adoption_30day AS adoption,
    calendar_adoption_30day / active_users_30day AS p_adoption
  FROM
    [YOUR_PROJECT_ID:adoption.adoption_all_products_30day] WHERE date = DATE(TIMESTAMP(YOUR_TIMESTAMP_PARAMETER))),
  (
  SELECT
    3 AS index,
    date,
    'Drive' AS product,
    drive_adoption_30day AS adoption,
    drive_adoption_30day / active_users_30day AS p_adoption
  FROM
    [YOUR_PROJECT_ID:adoption.adoption_all_products_30day] WHERE date = DATE(TIMESTAMP(YOUR_TIMESTAMP_PARAMETER))),
  (
  SELECT
    4 AS index,
    date,
    'Sheets' AS product,
    sheets_adoption_30day AS adoption,
    sheets_adoption_30day / active_users_30day AS p_adoption
  FROM
    [YOUR_PROJECT_ID:adoption.adoption_all_products_30day] WHERE date = DATE(TIMESTAMP(YOUR_TIMESTAMP_PARAMETER))),
  (
  SELECT
    5 AS index,
    date,
    'Slides' AS product,
    slides_adoption_30day AS adoption,
    slides_adoption_30day / active_users_30day AS p_adoption
  FROM
    [YOUR_PROJECT_ID:adoption.adoption_all_products_30day] WHERE date = DATE(TIMESTAMP(YOUR_TIMESTAMP_PARAMETER))),
  (
  SELECT
    6 AS index,
    date,
    'Docs' AS product,
    doc_adoption_30day AS adoption,
    doc_adoption_30day / active_users_30day AS p_adoption
  FROM
    [YOUR_PROJECT_ID:adoption.adoption_all_products_30day] WHERE date = DATE(TIMESTAMP(YOUR_TIMESTAMP_PARAMETER))),
  (
  SELECT
    7 AS index,
    date,
    'Forms' AS product,
    forms_adoption_30day AS adoption,
    forms_adoption_30day / active_users_30day AS p_adoption
  FROM
    [YOUR_PROJECT_ID:adoption.adoption_all_products_30day] WHERE date = DATE(TIMESTAMP(YOUR_TIMESTAMP_PARAMETER))),
  (
  SELECT
    8 AS index,
    date,
    'Meet' AS product,
    meet_adoption_30day AS adoption,
    meet_adoption_30day / active_users_30day AS p_adoption
  FROM
    [YOUR_PROJECT_ID:adoption.adoption_all_products_30day] WHERE date = DATE(TIMESTAMP(YOUR_TIMESTAMP_PARAMETER))),
  (
  SELECT
    9 AS index,
    date,
    'Google+' AS product,
    gplus_adoption_30day AS adoption,
    gplus_adoption_30day / active_users_30day AS p_adoption
  FROM
    [YOUR_PROJECT_ID:adoption.adoption_all_products_30day] WHERE date = DATE(TIMESTAMP(YOUR_TIMESTAMP_PARAMETER)))