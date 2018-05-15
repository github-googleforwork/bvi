SELECT
  *
FROM (
  SELECT
    "weekly" AS period,
    AVG(avg_prd_incr) AS productivity_increase,
    AVG(avg_coll_incr) AS collaboration_increase,
    AVG(avg_flexibility) AS flexibility,
    AVG(avg_innovation) AS innovation
  FROM
    [YOUR_PROJECT_ID:survey.impact_by_products_rates]
  WHERE
    frequency IN ('a few times a week',
      'every day')
    AND product != 'Google+'),
  (
  SELECT
    "monthly" AS period,
    AVG(avg_prd_incr) AS productivity_increase,
    AVG(avg_coll_incr) AS collaboration_increase,
    AVG(avg_flexibility) AS flexibility,
    AVG(avg_innovation) AS innovation
  FROM
    [YOUR_PROJECT_ID:survey.impact_by_products_rates]
  WHERE
    frequency IN ('a few times a month',
      'never')
    AND product != 'Google+')
