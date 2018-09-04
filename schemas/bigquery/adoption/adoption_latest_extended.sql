-- adoption_latest_extended (view)
-- Review: 10/10/2017
SELECT
  date,
  num_30day_logins AS active_users,
  num_used_licences AS num_total_users,
  suspended_users AS num_suspended_users,
  gmail_n30dau AS gmail_adoption,
  calendar_n30dau AS calendar_adoption,
  gplus_n30dau AS gplus_adoption,
  drive_n30dau AS drive_adoption,
  drive_n1dau AS drive_adoption_1d,
  docs_n30dau AS docs_adoption,
  sheets_n30dau AS sheets_adoption, 
  slides_n30dau AS slides_adoption,
  forms_n30dau AS forms_adoption,
  draws_n30dau as draws_adoption,
  drive_other_n30dau as other_drive_adoption,
  num_creators AS creators,
  num_collaborators AS collaborators,
  num_consumers AS consumers,
  num_sharers AS sharers,
  (drive_n30dau - (num_creators + num_collaborators + num_consumers + num_sharers)) AS idles,
  ROUND(num_30day_logins/num_used_licences, 2) AS P_active_users,
  ROUND(gmail_n30dau/num_30day_logins, 2) AS P_gmail_adoption,
  ROUND(calendar_n30dau/num_30day_logins, 2) AS P_calendar_adoption,
  ROUND(gplus_n30dau/num_30day_logins, 2) AS P_gplus_adoption,
  ROUND(drive_n30dau/num_30day_logins, 2) AS P_drive_adoption,
  ROUND(docs_n30dau/num_30day_logins, 2) AS P_docs_adoption,
  ROUND(sheets_n30dau/num_30day_logins, 2) AS P_sheets_adoption,
  ROUND(slides_n30dau/num_30day_logins, 2) AS P_slides_adoption,
  ROUND(forms_n30dau/num_30day_logins, 2) AS P_forms_adoption,
  ROUND(draws_n30dau/num_30day_logins, 2) AS P_draws_adoption,
  ROUND(drive_other_n30dau/num_30day_logins, 2) AS P_drive_other_adoption,
  ROUND(GREATEST(drive_n30dau, docs_n30dau, sheets_n30dau, forms_n30dau, slides_n30dau) /num_30day_logins, 2) AS P_Collaboration_Adoption,
  ROUND(num_creators/drive_n1dau, 2) AS P_creators,
  ROUND(num_collaborators/drive_n1dau, 2) AS P_collaborators,
  ROUND(num_consumers/drive_n1dau, 2) AS P_consumers,
  ROUND(num_sharers/drive_n1dau, 2) AS P_sharers,
  ROUND((drive_n1dau - GREATEST(num_creators, num_collaborators, num_consumers, num_sharers))/drive_n1dau, 2) AS P_idles
FROM
  [YOUR_PROJECT_ID:adoption.customer_usage_date_summary_extended]
WHERE
  _PARTITIONTIME >= DATE_ADD((SELECT MAX(date) FROM [YOUR_PROJECT_ID:adoption.adoption_30day]),-7,"DAY")
ORDER BY 1 DESC
LIMIT 1