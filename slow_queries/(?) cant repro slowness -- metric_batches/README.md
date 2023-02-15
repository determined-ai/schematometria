MetricBatches calls TrainingMetricBatches and ValidationMetricBatches

TrainingMetricBatche does

```
	err = db.queryRows(`
SELECT s.total_batches AS batches_processed,
  max(s.end_time) as end_time
FROM trials t INNER JOIN steps s ON t.id=s.trial_id
WHERE t.experiment_id=$1
  AND s.state = 'COMPLETED'
  AND s.metrics->'avg_metrics' ? $2
  AND s.end_time > $3
GROUP BY batches_processed;`, &rows, experimentID, metricName, startTime)
```

ValidationMetricBatches does

```
	err = db.queryRows(`
SELECT
  v.total_batches AS batches_processed,
  max(v.end_time) as end_time
FROM trials t
JOIN validations v ON t.id = v.trial_id
WHERE t.experiment_id=$1
  AND v.state = 'COMPLETED'
  AND v.metrics->'validation_metrics' ? $2
  AND v.end_time > $3
GROUP BY batches_processed`, &rows, experimentID, metricName, startTime)
```
