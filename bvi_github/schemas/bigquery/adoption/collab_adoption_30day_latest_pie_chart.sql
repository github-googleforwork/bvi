-- collab_adoption_30day_latest_pie_chart (view)

SELECT
  *
FROM (
  SELECT
    date,
    creators_30day,
    collaborators_30day,
    consumers_30day,
    sharers_30day,
    idles_30day,
    p_creators,
    p_collaborators,
    p_consumers,
    p_sharers,
    p_idles,
    'positive' AS type
  FROM
    [YOUR_PROJECT_ID:adoption.collab_adoption_30day_latest] ),
  (
  SELECT
    date,
    creators_30day,
    collaborators_30day,
    consumers_30day,
    sharers_30day,
    idles_30day,
    (1-p_creators) AS p_creators,
    (1-p_collaborators) AS p_collaborators,
    (1-p_consumers) AS p_consumers,
    (1-p_sharers) AS p_sharers,
    (1-p_idles) AS p_idles,
    'negative' AS type
  FROM
    [YOUR_PROJECT_ID:adoption.collab_adoption_30day_latest])
ORDER BY
  1 DESC
LIMIT
  2
