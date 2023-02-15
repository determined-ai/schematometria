EXPLAIN ANALYZE WITH mv AS (
  SELECT
    version,
    checkpoint_uuid,
    creation_time,
    name,
    comment,
    model_versions.id,
    metadata,
    labels,
    notes,
    username,
    user_id,
    last_updated_time
  FROM model_versions
  LEFT JOIN users ON users.id = model_versions.user_id
  WHERE model_id = 28
),
m AS (
  SELECT m.id, m.name, m.description, m.notes, m.metadata, m.creation_time, m.last_updated_time, array_to_json(m.labels) AS labels, u.username, m.user_id, m.archived, COUNT(mv.version) as num_versions
  FROM models as m
  JOIN users as u ON u.id = m.user_id
  LEFT JOIN model_versions as mv
    ON mv.model_id = m.id
  WHERE m.id = 28
  GROUP BY m.id, u.id
),
c AS (
SELECT
    c.uuid::text AS uuid,
    c.task_id,
    c.allocation_id,
    c.report_time as report_time,
    'STATE_' || c.state AS state,
    c.resources,
    c.metadata,
    -- Build a training substruct for protobuf.
    jsonb_build_object(
        'trial_id', c.trial_id,
        'experiment_id', c.experiment_id,
        'experiment_config', c.experiment_config,
        'hparams', c.hparams,
        -- construct training metrics from the untyped jsonb deterministically, since older
        -- versions may have old keys (e.g., num_inputs) and our unmarshaling is strict.
        'training_metrics', jsonb_build_object(
            'avg_metrics', c.training_metrics->'avg_metrics',
            'batch_metrics', c.training_metrics->'batch_metrics'
        ),
        'validation_metrics', json_build_object('avg_metrics', c.validation_metrics),
        'searcher_metric', c.searcher_metric
    ) AS training
FROM checkpoints_view c
  WHERE c.uuid IN (SELECT checkpoint_uuid FROM mv)
)
SELECT
    to_json(c) AS checkpoint,
    to_json(m) AS model,
    array_to_json(mv.labels) AS labels,
    mv.version, mv.id,
    mv.creation_time, mv.notes,
    mv.username, mv.user_id,
    mv.name, mv.comment, mv.metadata, mv.last_updated_time
    FROM c, mv, m
    WHERE c.uuid = mv.checkpoint_uuid::text;
