SELECT
  E__how_often_do_you_use_the_following_tools_docs AS frequency,
  count(E__how_often_do_you_use_the_following_tools_docs) as frequency_count
FROM
  [YOUR_PROJECT_ID:survey.form_responses]
WHERE
  E__how_often_do_you_use_the_following_tools_docs IS NOT NULL
GROUP BY frequency
