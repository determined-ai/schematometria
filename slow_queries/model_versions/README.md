looks like

```
c AS (
  SELECT *
  FROM proto_checkpoints_view c
  WHERE c.uuid IN (SELECT checkpoint_uuid::text FROM mv)
)
```

is the problematic part? `get_model_versions_after.sql` doesn't seem to resolve though....
