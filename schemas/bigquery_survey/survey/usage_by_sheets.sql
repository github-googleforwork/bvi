SELECT
  G__how_often_do_you_use_the_following_tools_sheets AS frequency,
  count(G__how_often_do_you_use_the_following_tools_sheets) as frequency_count
FROM
  [YOUR_PROJECT_ID:survey.form_responses]
WHERE
  G__how_often_do_you_use_the_following_tools_sheets IS NOT NULL
GROUP BY frequency
