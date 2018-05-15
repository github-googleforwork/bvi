SELECT
  H__how_often_do_you_use_the_following_tools_hangouts_chat AS frequency,
  count(H__how_often_do_you_use_the_following_tools_hangouts_chat) as frequency_count
FROM
  [YOUR_PROJECT_ID:survey.form_responses]
WHERE
  H__how_often_do_you_use_the_following_tools_hangouts_chat IS NOT NULL
GROUP BY frequency
