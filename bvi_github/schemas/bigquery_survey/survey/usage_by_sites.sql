SELECT
  J__how_often_do_you_use_the_following_tools_sites AS frequency,
  count(J__how_often_do_you_use_the_following_tools_sites) as frequency_count
FROM
  [YOUR_PROJECT_ID:survey.form_responses]
WHERE
  J__how_often_do_you_use_the_following_tools_sites IS NOT NULL
GROUP BY frequency
