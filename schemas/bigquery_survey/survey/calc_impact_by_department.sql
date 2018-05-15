SELECT
  (SUM(CASE
        WHEN positively_impact = 'Y' THEN 1
        ELSE 0 END) / SUM(CASE
        WHEN timestamp !='' THEN 1
        ELSE 0
      END )) AS positively_impacted_users,
  (SUM((CASE
          WHEN flexibility = 'strongly agree' THEN 1
          ELSE 0 END) + (CASE
          WHEN flexibility = 'agree' THEN 1
          ELSE 0 END)) / SUM(CASE
        WHEN flexibility != 'null' THEN 1
        ELSE 0
      END )) AS flexibility_percentage,
  (SUM((CASE
          WHEN innovation = 'strongly agree' THEN 1
          ELSE 0 END) + (CASE
          WHEN innovation = 'agree' THEN 1
          ELSE 0 END)) / SUM(CASE
        WHEN innovation != 'null' THEN 1
        ELSE 0
      END )) AS innovation_percentage
FROM
  [YOUR_PROJECT_ID:survey.impact_by_department]