SELECT
  index,
  product,
  frequency,
  AVG(productivity_increase) AS avg_prd_incr,
  AVG(collaboration_increase) AS avg_coll_incr,
  AVG(flexibility) AS avg_flexibility,
  AVG(innovation) AS avg_innovation,
  AVG(hours_saved_week) as avg_hours_saved_week 
FROM
  [YOUR_PROJECT_ID:survey.impact_by_products]
GROUP BY
  index,
  product,
  frequency
ORDER BY
  index
