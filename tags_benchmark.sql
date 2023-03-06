

CREATE TABLE tags (
    id INTEGER PRIMARY KEY,
    text text
);

INSERT INTO tags (id, text) values
    (1, 'tag1'),
    (2, 'tag2'),
    (3, 'tag3'),
    (4, 'tag4'),
    (5, 'tag5');


ALTER TABLE experiments ADD COLUMN tags jsonb;

UPDATE experiments
SET tags =
    CASE
        WHEN MOD(id, 5) < 1 THEN '{"tag1": ""}'::jsonb
        WHEN MOD(id, 5) < 2 THEN '{"tag1": "", "tag2": ""}'::jsonb
        WHEN MOD(id, 5) < 3 THEN '{"tag1": "", "tag2": "", "tag3": ""}'::jsonb
        WHEN MOD(id, 5) < 4 THEN '{"tag1": "", "tag2": "", "tag3": "", "tag4": ""}'::jsonb
        ELSE '{"tag1": "", "tag2": "", "tag3": "", "tag4": "", "tag5": ""}'::jsonb
    END;

CREATE INDEX experiment_tags_index ON experiments USING GIN (tags jsonb_path_ops);

CREATE TABLE experiment_taggings (
    experiment_id INTEGER references experiments (id),
    tag_id INTEGER REFERENCES tags (id)
);

INSERT INTO experiment_taggings (experiment_id, tag_id)
    SELECT id, SUBSTRING(jsonb_object_keys(tags), 4)::integer
    FROM experiments


-- averages about ~5ms on gcloud dump
select count(*) from experiments where tags ?| '{"tag3"}';

-- averages about ~15ms on gcloud dump
SELECT COUNT(DISTINCT e.id) FROM experiments e
    JOIN experiment_taggings et on et.experiment_id = e.id
    INNER JOIN tags t ON t.id = et.tag_id where t.text = ANY('{"tag3" }');
