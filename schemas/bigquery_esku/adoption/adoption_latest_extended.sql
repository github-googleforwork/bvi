-- adoption_latest_extended (view)
SELECT
  date,
  IFNULL(accounts.num_30day_logins,0) AS active_users,
  IFNULL(accounts.gsuite_enterprise_used_licenses,0) AS num_total_users,
  IFNULL(accounts.num_suspended_users,0) AS num_suspended_users,
  IFNULL(gmail.num_30day_active_users,0) AS gmail_adoption,
  IFNULL(calendar.num_30day_active_users,0) AS calendar_adoption,
  IFNULL(gplus.num_30day_active_users,0) AS gplus_adoption,
  IFNULL(drive.num_30day_active_users,0) AS drive_adoption,
  IFNULL(drive.num_1day_active_users,0) AS drive_adoption_1d,
  IFNULL(drive.num_30day_google_documents_active_users,0) AS docs_adoption,
  IFNULL(drive.num_30day_google_spreadsheets_active_users,0) AS sheets_adoption,
  IFNULL(drive.num_30day_google_presentations_active_users,0) AS slides_adoption,
  IFNULL(drive.num_30day_google_forms_active_users,0) AS forms_adoption,
  IFNULL(drive.num_30day_google_drawings_active_users,0) AS draws_adoption,
  IFNULL(drive.num_30day_other_types_active_users,0) AS other_drive_adoption,
  IFNULL(drive.num_creators,0) AS creators,
  IFNULL(drive.num_collaborators,0) AS collaborators,
  IFNULL(drive.num_consumers,0) AS consumers,
  IFNULL(drive.num_sharers,0) AS sharers,
  IFNULL((drive.num_30day_active_users - (drive.num_creators + drive.num_collaborators + drive.num_consumers + drive.num_sharers)),0) AS idles,
  IFNULL(ROUND(accounts.num_30day_logins/(accounts.gsuite_enterprise_used_licenses), 2),0) AS P_active_users,
  IFNULL(ROUND(gmail.num_30day_active_users/accounts.num_30day_logins, 2),0) AS P_gmail_adoption,
  IFNULL(ROUND(calendar.num_30day_active_users/accounts.num_30day_logins, 2),0) AS P_calendar_adoption,
  IFNULL(ROUND(gplus.num_30day_active_users/accounts.num_30day_logins, 2),0) AS P_gplus_adoption,
  IFNULL(ROUND(drive.num_30day_active_users/accounts.num_30day_logins, 2),0) AS P_drive_adoption,
  IFNULL(ROUND(drive.num_30day_google_documents_active_users/accounts.num_30day_logins, 2),0) AS P_docs_adoption,
  IFNULL(ROUND(drive.num_30day_google_spreadsheets_active_users/accounts.num_30day_logins, 2),0) AS P_sheets_adoption,
  IFNULL(ROUND(drive.num_30day_google_presentations_active_users/accounts.num_30day_logins, 2),0) AS P_slides_adoption,
  IFNULL(ROUND(drive.num_30day_google_forms_active_users/accounts.num_30day_logins, 2),0) AS P_forms_adoption,
  IFNULL(ROUND(drive.num_30day_google_drawings_active_users/accounts.num_30day_logins, 2),0) AS P_draws_adoption,
  IFNULL(ROUND(drive.num_30day_other_types_active_users/accounts.num_30day_logins, 2),0) AS P_drive_other_adoption,
  IFNULL(ROUND(GREATEST(drive.num_30day_active_users, drive.num_30day_google_documents_active_users, drive.num_30day_google_spreadsheets_active_users, drive.num_30day_google_forms_active_users, drive.num_30day_google_presentations_active_users) / accounts.num_30day_logins, 2),0) AS P_Collaboration_Adoption,
  IFNULL(ROUND(drive.num_creators/drive.num_1day_active_users, 2),0) AS P_creators,
  IFNULL(ROUND(drive.num_collaborators/drive.num_1day_active_users, 2),0) AS P_collaborators,
  IFNULL(ROUND(drive.num_consumers/drive.num_1day_active_users, 2),0) AS P_consumers,
  IFNULL(ROUND(drive.num_sharers/drive.num_1day_active_users, 2),0) AS P_sharers,
  IFNULL(ROUND((drive.num_1day_active_users - GREATEST(drive.num_creators, drive.num_collaborators, drive.num_consumers, drive.num_sharers))/drive.num_1day_active_users, 2),0) AS P_idles
FROM
  [YOUR_PROJECT_ID:Reports.usage] customer_usage
WHERE TRUE
  AND _PARTITIONTIME >= DATE_ADD((SELECT MAX(date) FROM [YOUR_PROJECT_ID:adoption.adoption_30day]),-7,"DAY")
  AND _PARTITIONTIME <= TIMESTAMP((SELECT MAX(date) FROM [YOUR_PROJECT_ID:adoption.adoption_30day]))
  AND record_type = 'customer'
ORDER BY 1 DESC
LIMIT 1