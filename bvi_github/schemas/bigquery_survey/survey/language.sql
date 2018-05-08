SELECT
  LOWER(original_options) as original, LOWER(new_language_option) as new_language
FROM (
  SELECT
    'Strongly Agree' AS original_options,
    'Strongly Agree' AS new_language_option),
  (
  SELECT
    'Agree' AS original_options,
    'Agree' AS new_language_option),
  (
  SELECT
    'No Change' AS original_options,
    'No Change' AS new_language_option),
  (
  SELECT
    'Disagree' AS original_options,
    'Disagree' AS new_language_option),
  (
  SELECT
    'Strongly Disagree' AS original_options,
    'Strongly Disagree' AS new_language_option),
  (
  SELECT
    'Never' AS original_options,
    'Never' AS new_language_option),
  (
  SELECT
    'A few times a month' AS original_options,
    'A few times a month' AS new_language_option),
  (
  SELECT
    'A few times a week' AS original_options,
    'A few times a week' AS new_language_option),
  (
  SELECT
    'Every day' AS original_options,
    'Every day' AS new_language_option)
