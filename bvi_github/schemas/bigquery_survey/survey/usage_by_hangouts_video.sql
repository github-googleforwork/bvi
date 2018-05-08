SELECT
  I__how_often_do_you_use_the_following_tools_hangouts_video AS frequency,
  count(I__how_often_do_you_use_the_following_tools_hangouts_video) as frequency_count
FROM
  [YOUR_PROJECT_ID:survey.form_responses]
WHERE
  I__how_often_do_you_use_the_following_tools_hangouts_video IS NOT NULL
GROUP BY frequency
