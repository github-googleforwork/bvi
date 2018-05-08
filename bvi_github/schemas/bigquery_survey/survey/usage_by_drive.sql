SELECT
  D__how_often_do_you_use_the_following_tools_drive AS frequency,
  count(D__how_often_do_you_use_the_following_tools_drive) as frequency_count
FROM
  [YOUR_PROJECT_ID:survey.form_responses]
WHERE
  D__how_often_do_you_use_the_following_tools_drive IS NOT NULL
GROUP BY frequency
