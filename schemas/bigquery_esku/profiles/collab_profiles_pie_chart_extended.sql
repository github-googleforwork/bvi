-- collab_profiles_pie_chart_extended (view)
-- Review: 10/08/2017
SELECT
  *
FROM (SELECT date, 'creators' as type, creators as count, ROUND (creators / drive_adoption_1d, 2) P_count
      FROM [YOUR_PROJECT_ID:adoption.adoption_latest_extended] ) data1,
     (SELECT date, 'non_creators' as type, (drive_adoption_1d - creators) as count, ROUND ((drive_adoption_1d - creators) / drive_adoption_1d, 2) P_count
      FROM [YOUR_PROJECT_ID:adoption.adoption_latest_extended] ) data2,
     (SELECT date, 'collaborators' as type, collaborators as count, ROUND (collaborators / drive_adoption_1d, 2) P_count
      FROM [YOUR_PROJECT_ID:adoption.adoption_latest_extended] ) data3,
     (SELECT date, 'non_collaborators' as type, (drive_adoption_1d - collaborators) as count, ROUND ((drive_adoption_1d - collaborators) / drive_adoption_1d, 2) P_count
      FROM [YOUR_PROJECT_ID:adoption.adoption_latest_extended] ) data4,
     (SELECT date, 'consumers' as type, consumers as count, ROUND (consumers / drive_adoption_1d, 2) P_count
      FROM [YOUR_PROJECT_ID:adoption.adoption_latest_extended] ) data5,
     (SELECT date, 'non_consumers' as type, (drive_adoption_1d - consumers) as count, ROUND ((drive_adoption_1d - consumers) / drive_adoption_1d, 2) P_count
      FROM [YOUR_PROJECT_ID:adoption.adoption_latest_extended] ) data6,
     (SELECT date, 'sharers' as type, sharers as count, ROUND (sharers / drive_adoption_1d, 2) P_count
      FROM [YOUR_PROJECT_ID:adoption.adoption_latest_extended] ) data7,
     (SELECT date, 'non_sharers' as type, (drive_adoption_1d - sharers) as count, ROUND ((drive_adoption_1d - sharers) / drive_adoption_1d, 2) P_count
      FROM [YOUR_PROJECT_ID:adoption.adoption_latest_extended] ) data8,
     (SELECT date, 'idle' as type, (drive_adoption_1d - GREATEST(creators, collaborators, consumers, sharers)) as count, ROUND ((drive_adoption_1d - GREATEST(creators, collaborators, consumers, sharers)) / drive_adoption_1d, 2) P_count
      FROM [YOUR_PROJECT_ID:adoption.adoption_latest_extended] ) data9,
     (SELECT date, 'non_idle' as type, GREATEST(creators, collaborators, consumers, sharers) as count, ROUND (GREATEST(creators, collaborators, consumers, sharers)/ drive_adoption_1d, 2) P_count
      FROM [YOUR_PROJECT_ID:adoption.adoption_latest_extended] ) data10