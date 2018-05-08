SELECT
  AVG(index ) AS index,
  product,
  ((AVG(avg_prd_incr) + AVG(avg_innovation) + AVG(avg_coll_incr) + AVG(avg_flexibility)) / 4) AS avg_impact,
  AVG(avg_hours_saved_week) AS avg_saved_week
FROM
  [YOUR_PROJECT_ID:survey.impact_by_products_rates]
WHERE
  frequency IN ('a few times a month',
    'a few times a week',
    'every day')
GROUP BY
  product