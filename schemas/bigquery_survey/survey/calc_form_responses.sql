SELECT
  (SUM(AC_degree_has_your_collaboration_with_colleagues_on_work_increased_or_decreased_when_using_g_suite) + SUM(AD_degree_has_your_ability_to_connect_with_colleagues_outside_of_your_primary_location_changed_since_using_google_apps_DEPR)) / (SUM(CASE
        WHEN AC_degree_has_your_collaboration_with_colleagues_on_work_increased_or_decreased_when_using_g_suite IS NULL THEN 0
        ELSE 1
      END ) + SUM(CASE
        WHEN AD_degree_has_your_ability_to_connect_with_colleagues_outside_of_your_primary_location_changed_since_using_google_apps_DEPR IS NULL THEN 0
        ELSE 1
      END )) AS collaboration,
  AVG(AB_degree_has_your_productivity_increased_or_decreased_when_using_g_suite ) AS productivity,
  AVG(AK_how_many_hours_do_you_save_or_expect_to_save_per_week_using_g_suite) AS avg_hours_saved,
  AVG(M__how_well_would_you_rate_your_ability_to_use_the_following_products_drive) AS avg_drive,
  AVG(N__how_well_would_you_rate_your_ability_to_use_the_following_products_docs) AS avg_docs,
  AVG(O__how_well_would_you_rate_your_ability_to_use_the_following_products_slides) AS avg_slides,
  AVG(P__how_well_would_you_rate_your_ability_to_use_the_following_products_sheets) AS avg_sheets,
  AVG(Q__how_well_would_you_rate_your_ability_to_use_the_following_products_hangouts_chat) AS avg_hangouts_chat,
  AVG(R__how_well_would_you_rate_your_ability_to_use_the_following_products_hangouts_video) AS avg_hangouts_video,
  AVG(S__how_well_would_you_rate_your_ability_to_use_the_following_products_sites) AS avg_sites,
  AVG(T__how_well_would_you_rate_your_ability_to_use_the_following_products_forms) AS avg_forms,
  AVG(U__how_well_would_you_rate_your_ability_to_use_the_following_products_google_plus) AS avg_gplus
FROM
  [YOUR_PROJECT_ID:survey.form_responses]