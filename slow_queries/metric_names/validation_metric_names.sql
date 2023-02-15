SELECT
  jsonb_object_keys(v.metrics->'validation_metrics') AS name,
  max(v.end_time) AS end_time
FROM trials t
JOIN validations v ON t.id = v.trial_id
WHERE t.experiment_id=$1
  AND v.end_time > $2
GROUP BY name