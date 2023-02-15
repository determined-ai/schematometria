SELECT
  "e"."id",
  e.config->>$1 AS description,
  e.config->>$2 AS labels,
  proto_time(e.start_time) AS start_time,
  proto_time(e.end_time) AS end_time,
  CASE e.state::text
    WHEN $3 THEN $4
    WHEN $5 THEN $6
    WHEN $7 THEN $8
    WHEN $9 THEN $10
    WHEN $11 THEN $12
    WHEN $13 THEN $14
    WHEN $15 THEN $16
    WHEN $17 THEN $18
    WHEN $19 THEN $20
    WHEN $21 THEN $22
    WHEN $23 THEN $24
    WHEN $25 THEN $26
    WHEN $27 THEN $28
    WHEN $29 THEN $30
    WHEN $31 THEN $32
    WHEN $33 THEN $34
    WHEN $35 THEN $36
END
  AS state,
  "e"."archived",
  (
  SELECT
    COUNT(*)
  FROM
    trials t
  WHERE
    e.id = t.experiment_id) AS num_trials,
  COALESCE(u.display_name, u.username) AS display_name,
  e.owner_id AS user_id,
  "u"."username",
  e.config->$37->>$38 AS resource_pool,
  e.config->$39->>$40 AS searcher_type,
  e.config->>$41 AS NAME,
  CASE
    WHEN NULLIF(e.notes, $42) IS NULL THEN $43
  ELSE
  $44
END
  AS notes,
  "e"."job_id",
  CASE
    WHEN e.parent_id IS NULL THEN $45
  ELSE
  json_build_object($46,
    e.parent_id)
END
  AS forked_from,
  CASE
    WHEN e.progress IS NULL THEN $47
  ELSE
  json_build_object($48,
    e.progr