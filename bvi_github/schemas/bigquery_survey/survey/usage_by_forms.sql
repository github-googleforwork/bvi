SELECT
  K__how_often_do_you_use_the_following_tools_forms AS frequency,
  count(K__how_often_do_you_use_the_following_tools_forms) as frequency_count
FROM
  [YOUR_PROJECT_ID:survey.form_responses]
WHERE
  K__how_often_do_you_use_the_following_tools_forms IS NOT NULL
GROUP BY frequency
