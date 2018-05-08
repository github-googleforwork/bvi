SELECT
  department,
  COUNT(department) AS count_department,
  AVG(positive_impact) AS avg_p_positive_impact,
  AVG(negative_impact) AS avg_p_negative_impact,
  AVG(innovation_impact) as avg_innovation_impact,
  AVG(flexibility_impact) as avg_flexibility_impact
FROM
  [YOUR_PROJECT_ID:survey.impact_by_department]
GROUP BY
  department