WITH const AS (
    SELECT config->'searcher'->>'metric' AS metric_name,
           (CASE
                WHEN coalesce((config->'searcher'->>'smaller_is_better')::boolean, true)
                THEN 1
                ELSE -1
            END) AS sign
    FROM experiments WHERE id = $1
), selected_checkpoints AS (
    SELECT *
    FROM (
        SELECT *,
               -- The order includes the id to prevent different rows from having the same
               -- rank, which could cause more than the desired number of checkpoints to be
               -- left out of the result set. Also, any rows with null validation values
               -- will sort to the end, thereby not affecting the ranks of rows with
               -- non-null validations, and will be filtered out later.
               rank() OVER (
                   ORDER BY
                       const.sign * (step->'validation'->'metrics'->'validation_metrics'
                                     ->>const.metric_name)::float8 ASC NULLS LAST, id ASC
               ) AS experiment_rank,
               rank() OVER (
                   PARTITION BY trial_id
                   ORDER BY
                       const.sign * (step->'validation'->'metrics'->'validation_metrics'
                                     ->>const.metric_name)::float8 ASC NULLS LAST, id ASC
               ) AS trial_rank,
               rank() OVER (
                   PARTITION BY trial_id
                   ORDER BY total_batches DESC
               ) AS trial_order_rank
        FROM (
            SELECT c.id, c.trial_id, c.steps_completed as total_batches, c.state,
                   c.report_time as end_time, c.uuid, c.resources, c.metadata,
                   (SELECT row_to_json(s)
                    FROM (
                        SELECT s.end_time, s.id, s.state, s.trial_id,
                            s.total_batches,
                            (SELECT row_to_json(v)
                            FROM (
                                SELECT v.end_time, v.id, v.metrics,
                                    v.state, v.total_batches, v.trial_id
                                    FROM validations v
                                    WHERE v.trial_id = t.id AND v.total_batches = s.total_batches
                                ) v
                               ) AS validation
                        FROM steps s
                        WHERE s.total_batches = c.steps_completed AND s.trial_id = c.trial_id
                    ) s
                   ) AS step,
                   -- We later filter out any checkpoints with any corresponding warm start
                   -- trials, so we can just put an empty list here. (TODO(dzhu): This is
                   -- here for backwards compatibility with Python, but could maybe be
                   -- removed.)
                   '[]'::jsonb AS warm_start_trials
            FROM checkpoints_view c, trials t, const
            WHERE c.state = 'COMPLETED' AND c.trial_id = t.id AND t.experiment_id = $1
        ) _, const
    ) c, const
    WHERE (SELECT COUNT(*) FROM trials t WHERE t.warm_start_checkpoint_id = c.id) = 0
          AND c.trial_order_rank > $4
          AND ((c.experiment_rank > $2
                AND c.trial_rank > $3)
               OR (c.step->'validation'->'metrics'->'validation_metrics'->>const.metric_name
                   IS NULL))
)
SELECT selected_checkpoints.uuid AS ID from selected_checkpoints;