SELECT s.total_batches AS batches_processed,
  max(s.end_time) as end_time
FROM trials t INNER JOIN steps s ON t.id=s.trial_id
WHERE t.experiment_id=1754
  AND s.state = 'COMPLETED'::step_state
  AND s.metrics->'avg_metrics' ? 'loss'::text
  AND s.end_time > '0001-01-01 00:00:00+00'::timestamp with time zone
GROUP BY batches_processed