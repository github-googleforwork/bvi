SELECT
  timestamp,
  department,
  productivity,
  collaboration,
  flexibility,
  innovation,
  positive_impact,
  negative_impact,
  (CASE
      WHEN positive_impact > 0 THEN 'Y'
      ELSE '' END) AS positively_impact,
  flexibility_impact,
  innovation_impact
FROM (
  SELECT
    responses.A__timestamp AS timestamp,
    responses.B__business_function AS department,
    responses.AB_degree_has_your_productivity_increased_or_decreased_when_using_g_suite AS productivity,
    responses.AC_degree_has_your_collaboration_with_colleagues_on_work_increased_or_decreased_when_using_g_suite AS collaboration,
    lang_flex.original flexibility,
    lang_inno.original innovation,
    ((CASE
          WHEN AB_degree_has_your_productivity_increased_or_decreased_when_using_g_suite > 0 THEN 1
          ELSE 0 END) + (CASE
          WHEN AC_degree_has_your_collaboration_with_colleagues_on_work_increased_or_decreased_when_using_g_suite > 0 THEN 1
          ELSE 0 END) + (CASE
          WHEN lang_flex.original = 'strongly agree' OR lang_flex.original = 'agree' THEN 1
          ELSE 0 END)+ (CASE
          WHEN lang_inno.original = 'strongly agree' OR lang_inno.original = 'agree' THEN 1
          ELSE 0 END))/4 AS positive_impact,
    ((CASE
          WHEN AB_degree_has_your_productivity_increased_or_decreased_when_using_g_suite < 0 THEN 1
          ELSE 0 END) + (CASE
          WHEN AC_degree_has_your_collaboration_with_colleagues_on_work_increased_or_decreased_when_using_g_suite < 0 THEN 1
          ELSE 0 END) + (CASE
          WHEN lang_flex.original = 'strongly disagree' OR lang_flex.original = 'disagree' THEN 1
          ELSE 0 END)+ (CASE
          WHEN lang_inno.original = 'strongly disagree' OR lang_inno.original = 'disagree' THEN 1
          ELSE 0 END))/4 AS negative_impact,
    CASE
      WHEN lang_flex.original = 'strongly agree' THEN 1
      WHEN lang_flex.original = 'agree' THEN 0.5
      WHEN lang_flex.original = 'no change' THEN 0
      WHEN lang_flex.original = 'disagree' THEN -0.5
      WHEN lang_flex.original = 'strongly disagree' THEN -1
      ELSE 0
    END AS flexibility_impact,
    CASE
      WHEN lang_inno.original = 'strongly agree' THEN 1
      WHEN lang_inno.original = 'agree' THEN 0.5
      WHEN lang_inno.original = 'no change' THEN 0
      WHEN lang_inno.original = 'disagree' THEN -0.5
      WHEN lang_inno.original = 'strongly disagree' THEN -1
      ELSE 0
    END AS innovation_impact
  FROM
    [YOUR_PROJECT_ID:survey.form_responses] responses
  LEFT JOIN
    [YOUR_PROJECT_ID:survey.language] lang_flex
  ON
    lang_flex.new_language = responses.AG_degree_do_you_agree_or_disagree_as_a_result_of_using_g_suite_i_am_more_flexible_in_where_i_can_work_and_or_what_device_i_use
  LEFT JOIN
    [YOUR_PROJECT_ID:survey.language] lang_inno
  ON
    lang_inno.new_language = responses.AH_degree_do_you_agree_or_disagree_to_the_as_a_result_of_using_g_suite_my_organization_is_more_innovative)
