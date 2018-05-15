SELECT
  products.index as index,
  products.product as product,
  frequency,
  responses.inner_responses.productivity_increase as productivity_increase,
  responses.inner_responses.collaboration_increase as collaboration_increase,
  responses.inner_responses.hours_saved_week AS hours_saved_week,
  responses.innovation AS innovation,
  responses.flexibility AS flexibility
FROM (
  SELECT
    index,
    product,
    CASE
      WHEN product = 'Drive' THEN responses.D__how_often_do_you_use_the_following_tools_drive
      WHEN product = 'Docs' THEN responses.E__how_often_do_you_use_the_following_tools_docs
      WHEN product = 'Sheets' THEN responses.G__how_often_do_you_use_the_following_tools_sheets
      WHEN product = 'Slides' THEN responses.F__how_often_do_you_use_the_following_tools_slides
      WHEN product = 'Forms' THEN responses.K__how_often_do_you_use_the_following_tools_forms
      WHEN product = 'Sites' THEN responses.J__how_often_do_you_use_the_following_tools_sites
      WHEN product = 'Hangouts (Chat)' THEN responses.H__how_often_do_you_use_the_following_tools_hangouts_chat
      WHEN product = 'Hangouts (Video)' THEN responses.I__how_often_do_you_use_the_following_tools_hangouts_video
      WHEN product = 'Google+' THEN responses.L__how_often_do_you_use_the_following_tools_google_plus
    END frequency,
    responses.AB_degree_has_your_productivity_increased_or_decreased_when_using_g_suite AS productivity_increase,
    responses.AC_degree_has_your_collaboration_with_colleagues_on_work_increased_or_decreased_when_using_g_suite AS collaboration_increase,
    responses.AK_how_many_hours_do_you_save_or_expect_to_save_per_week_using_g_suite AS hours_saved_week,
    innovation,
    flexibility
  FROM (
    SELECT
      "a" AS temp,
      D__how_often_do_you_use_the_following_tools_drive,
      E__how_often_do_you_use_the_following_tools_docs,
      G__how_often_do_you_use_the_following_tools_sheets,
      F__how_often_do_you_use_the_following_tools_slides,
      K__how_often_do_you_use_the_following_tools_forms,
      J__how_often_do_you_use_the_following_tools_sites,
      H__how_often_do_you_use_the_following_tools_hangouts_chat,
      I__how_often_do_you_use_the_following_tools_hangouts_video,
      L__how_often_do_you_use_the_following_tools_google_plus,
      AB_degree_has_your_productivity_increased_or_decreased_when_using_g_suite,
      AC_degree_has_your_collaboration_with_colleagues_on_work_increased_or_decreased_when_using_g_suite,
      AK_how_many_hours_do_you_save_or_expect_to_save_per_week_using_g_suite,
      CASE
        WHEN lang_flex.original = 'strongly agree' THEN 1
        WHEN lang_flex.original = 'agree' THEN 0.5
        WHEN lang_flex.original = 'no change' THEN 0
        WHEN lang_flex.original = 'disagree' THEN -0.5
        WHEN lang_flex.original = 'strongly disagree' THEN -1
        ELSE 0
      END AS flexibility,
      CASE
        WHEN lang_inno.original = 'strongly agree' THEN 1
        WHEN lang_inno.original = 'agree' THEN 0.5
        WHEN lang_inno.original = 'no change' THEN 0
        WHEN lang_inno.original = 'disagree' THEN -0.5
        WHEN lang_inno.original = 'strongly disagree' THEN -1
        ELSE 0
      END AS innovation
    FROM
      [YOUR_PROJECT_ID:survey.form_responses] inner_responses
    LEFT JOIN
      [YOUR_PROJECT_ID:survey.language] lang_flex
    ON
      lang_flex.new_language = inner_responses.AG_degree_do_you_agree_or_disagree_as_a_result_of_using_g_suite_i_am_more_flexible_in_where_i_can_work_and_or_what_device_i_use
    LEFT JOIN
      [YOUR_PROJECT_ID:survey.language] lang_inno
    ON
      lang_inno.new_language = inner_responses.AH_degree_do_you_agree_or_disagree_to_the_as_a_result_of_using_g_suite_my_organization_is_more_innovative ) responses
  JOIN (
    SELECT
      temp,
      index,
      product
    FROM (
      SELECT
        "a" temp,
        0.0001 AS index,
        'Drive' AS product),
      (
      SELECT
        "a" temp,
        0.0002 AS index,
        'Docs' AS product),
      (
      SELECT
        "a" temp,
        0.0003 AS index,
        'Sheets' AS product),
      (
      SELECT
        "a" temp,
        0.0004 AS index,
        'Slides' AS product),
      (
      SELECT
        "a" temp,
        0.0005 AS index,
        'Forms' AS product),
      (
      SELECT
        "a" temp,
        0.0006 AS index,
        'Sites' AS product),
      (
      SELECT
        "a" temp,
        0.0007 AS index,
        'Hangouts (Chat)' AS product),
      (
      SELECT
        "a" temp,
        0.0008 AS index,
        'Hangouts (Video)' AS product),
      (
      SELECT
        "a" temp,
        0.0009 AS index,
        'Google+' AS product)) AS products
  ON
    products.temp = responses.temp)
WHERE
  frequency IS NOT NULL
