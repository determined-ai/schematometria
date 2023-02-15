-- during release party
-- Avg execution time (ms) 7,475.43
-- Times called: 150 
-- Avg rows returned: 1


WITH
  "size_and_count" AS (
  WITH
    "cp_size_tuple" AS (
    SELECT
      jsonb_each(c.resources) AS size_tuple,
      "experiment_id",
      "uuid",
      "trial_id"
    FROM
      checkpoints_view AS c
    WHERE
      (state != $1)
      AND (c.resources != $2::jsonb)
      AND (trial_id IN (
        SELECT
          DISTINCT "trial_id"
        FROM
          "checkpoints_view"
        WHERE
          (uuid IN ($3))))),
    "trial_ids" AS (
    SELECT
      DISTINCT "trial_id"
    FROM
      "checkpoints_view"
    WHERE
      (uuid IN ($4)))
  SELECT
    COALESCE(SUM((size_tuple).value::text::bigint), $5) AS size,
    COUNT(DISTINCT(uuid)) AS count,
    trial_ids.trial_id
  FROM
    "cp_size_tuple"
  RIGHT JOIN
    trial_ids
  ON
    trial_ids.trial_id = cp_size_tuple.trial_id
  GROUP BY
    trial_ids.trial_id)
UPDATE
  "trials"
SET
  checkpoint_size = size,
  checkpoint_count = count
FROM
  "size_and_count"
WHERE
  (id IN (
    SELECT
      DISTINCT "trial_id"
    FROM
      "checkpoints_view"
    WHERE
      (uuid IN ($6))))
  AND (trials.id = size_and_count.trial_id)