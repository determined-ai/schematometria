SELECT
  jsonb_object_keys(s.metrics->'avg_metrics') AS name,
  max(s.end_time) AS end_time
FROM trials t
JOIN steps s ON t.id=s.trial_id
WHERE t.experiment_id=2217
  AND s.end_time > now()
GROUP BY name