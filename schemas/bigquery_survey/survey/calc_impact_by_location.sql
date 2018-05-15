SELECT
  location,
  AVG(positive_impact ) AS avg_p_positive_impact,
  AVG(negative_impact) AS avg_p_negative_impact,
  COUNT(location) AS count_location
FROM
  [YOUR_PROJECT_ID:survey.impact_by_location]
GROUP BY
  location