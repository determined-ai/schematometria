WITH
  "size_and_count" AS (
  SELECT
    COALESCE(SUM(checkpoint_size), $1) AS size,
    COALESCE(SUM(checkpoint_count), $2) AS count,
    "experiment_id"
  FROM
    "trials"
  WHERE
    (experiment_id IN (
      SELECT
        DISTINCT "experiment_id"
      FROM
        "checkpoints_view"
      WHERE
        (uuid IN ($3))))
  GROUP BY
    "experiment_id")
UPDATE
  "experiments"
SET
  checkpoint_size = size,
  checkpoint_count = count
FROM
  "size_and_count"
WHERE
  (id IN (
    SELECT
      DISTINCT "experiment_id"
    FROM
      "checkpoints_view"
    WHERE
      (uuid IN ($4))))
  AND (experiments.id = experiment_id)