SELECT
  L__how_often_do_you_use_the_following_tools_google_plus AS frequency,
  count(L__how_often_do_you_use_the_following_tools_google_plus) as frequency_count
FROM
  [YOUR_PROJECT_ID:survey.form_responses]
WHERE
  L__how_often_do_you_use_the_following_tools_google_plus IS NOT NULL
GROUP BY frequency
