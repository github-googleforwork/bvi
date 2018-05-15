-- required name of view: user_usage_text_documents_daily
-- Review: 16/03/2017
SELECT
  user_usage.date AS date,
  user_usage.email AS email,
  IFNULL(users.ou, 'NA') AS ou,
  user_usage.num_docs_created AS num_text_documents,
  user_usage.num_docs_created as num_text_docs_created,
  user_usage.num_docs_edited as num_text_docs_edited,
  user_usage.num_docs_trashed as num_text_docs_trashed,
  user_usage.num_docs_viewed as num_text_docs_viewed  
FROM (
  SELECT
    date,
    entity.userEmail AS email,
    IF(parameters.name = "drive:num_owned_google_documents_created",IFNULL(parameters.intValue,NULL), 0) as num_docs_created,
    IF(parameters.name = "drive:num_owned_google_documents_edited",IFNULL(parameters.intValue,NULL),0) as num_docs_edited,
    IF(parameters.name = "drive:num_owned_google_documents_trashed",IFNULL(parameters.intValue,NULL),0) as num_docs_trashed,
    IF(parameters.name = "drive:num_owned_google_documents_viewed",IFNULL(parameters.intValue,NULL),0) as num_docs_viewed
  FROM
    [YOUR_PROJECT_ID:raw_data.user_usage]
  WHERE
    _PARTITIONTIME = YOUR_TIMESTAMP_PARAMETER
    AND parameters.name IN ('drive:num_owned_google_documents_created', 'drive:num_owned_google_documents_edited', 'drive:num_owned_google_documents_trashed', 'drive:num_owned_google_documents_viewed' )
    AND parameters.intValue > 0 )user_usage
LEFT JOIN (
  SELECT
    ou,
    email
  FROM
    [YOUR_PROJECT_ID:users.users_ou_list]
  WHERE
    TRUE
    AND _PARTITIONTIME = YOUR_TIMESTAMP_PARAMETER) users
ON
  users.email = user_usage.email
GROUP BY 1,2,3,4,5,6,7,8