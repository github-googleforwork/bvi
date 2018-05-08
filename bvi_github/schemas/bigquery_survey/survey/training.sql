SELECT
  methods.index AS index,
  methods.method AS method,
  grade,
FROM (
  SELECT
    index,
    method,
    CASE
      WHEN method = 'Classroom' THEN training.grade_classroom
      WHEN method = 'Online' THEN training.grade_online
      WHEN method = 'Google Sites' THEN training.grade_sites
      WHEN method = 'Peers/Google Guides' THEN training.grade_peer
      WHEN method = 'Other' THEN training.grade_other
    END grade
  FROM (
    SELECT
      "a" AS temp,
      AVG(V__how_helpful_did_or_do_you_find_the_following_training_resources_in_class_training) AS grade_classroom,
      AVG(W__how_helpful_did_or_do_you_find_the_following_training_resources_online_training) AS grade_online,
      AVG(X__how_helpful_did_or_do_you_find_the_following_training_resources_going_google_site) AS grade_sites,
      AVG(Y__how_helpful_did_or_do_you_find_the_following_training_resources_peer_support_google_guides) AS grade_peer,
      AVG(Z__how_helpful_did_or_do_you_find_the_following_training_resources_other) AS grade_other
    FROM
      [YOUR_PROJECT_ID:survey.form_responses] inner_training) training
  JOIN (
    SELECT
      temp,
      index,
      method
    FROM (
      SELECT
        "a" temp,
        0.0001 AS index,
        "Classroom" AS method ),
      (
      SELECT
        "a" temp,
        0.0002 AS index,
        "Online" AS method ),
      (
      SELECT
        "a" temp,
        0.0003 AS index,
        "Google Sites" AS method),
      (
      SELECT
        "a" temp,
        0.0004 AS index,
        "Peers/Google Guides" AS method),
      (
      SELECT
        "a" temp,
        0.0005 AS index,
        "Other" AS method) ) AS methods
  ON
    methods.temp = training.temp)
