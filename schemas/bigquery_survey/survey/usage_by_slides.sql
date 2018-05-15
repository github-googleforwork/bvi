SELECT
  F__how_often_do_you_use_the_following_tools_slides AS frequency,
  count(F__how_often_do_you_use_the_following_tools_slides) as frequency_count
FROM
  [YOUR_PROJECT_ID:survey.form_responses]
WHERE
  F__how_often_do_you_use_the_following_tools_slides IS NOT NULL
GROUP BY frequency
