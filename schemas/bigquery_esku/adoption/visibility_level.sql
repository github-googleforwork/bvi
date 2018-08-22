-- visibility_level (view)
SELECT
  public_level, visibility
FROM (
  SELECT
    0 AS public_level,
    'unknown' AS visibility),
  (
  SELECT
    1 AS public_level,
    'private' AS visibility),
  (
  SELECT
    2 AS public_level,
    'shared_internally' AS visibility),
  (
  SELECT
    3 AS public_level,
    'people_within_domain_with_link' AS visibility),
  (
  SELECT
    4 AS public_level,
    'public_in_the_domain' AS visibility),
  (
  SELECT
    5 AS public_level,
    'shared_externally' AS visibility),
  (
  SELECT
    6 AS public_level,
    'people_with_link' AS visibility),
  (
  SELECT
    7 AS public_level,
    'public_on_the_web' AS visibility)