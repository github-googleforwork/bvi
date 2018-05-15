-- adoption_per_product
-- Review: 01/03/2018

SELECT date, index, product, p_adoption FROM
(SELECT date, 1 as index, 'Gmail' as product, p_gmail_adoption as p_adoption FROM [YOUR_PROJECT_ID:adoption.adoption_30day_latest]),
(SELECT date, 2 as index, 'Calendar' as product, p_calendar_adoption as p_adoption FROM [YOUR_PROJECT_ID:adoption.adoption_latest_extended]),
(SELECT date, 3 as index, 'Drive' as product, p_drive_adoption as p_adoption FROM [YOUR_PROJECT_ID:adoption.adoption_30day_latest]),
(SELECT date, 4 as index, 'Sheets' as product, p_sheets_adoption as p_adoption FROM [YOUR_PROJECT_ID:adoption.adoption_30day_latest]),
(SELECT date, 5 as index, 'Slides' as product, p_slides_adoption as p_adoption FROM [YOUR_PROJECT_ID:adoption.adoption_30day_latest]),
(SELECT date, 6 as index, 'Docs' as product, p_doc_adoption as p_adoption FROM [YOUR_PROJECT_ID:adoption.adoption_30day_latest]),
(SELECT date, 7 as index, 'Forms' as product, p_forms_adoption as p_adoption FROM [YOUR_PROJECT_ID:adoption.adoption_30day_latest]),
(SELECT date, 8 as index, 'Meet' as product, p_meet_adoption as p_adoption FROM [YOUR_PROJECT_ID:adoption.adoption_30day_latest]),
(SELECT date, 9 as index, 'Google+' as product, p_gplus_adoption as p_adoption FROM [YOUR_PROJECT_ID:adoption.adoption_latest_extended])

