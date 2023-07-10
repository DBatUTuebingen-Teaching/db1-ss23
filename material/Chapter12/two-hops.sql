-- Reformulate the algebraic two-hop query in SQL:
-- node in the RA operator tree ≡ SQL subquery in (...)

DROP TABLE IF EXISTS g;

CREATE TABLE g ("from" text NOT NULL,
                "to"   text NOT NULL);
ALTER TABLE g ADD PRIMARY KEY ("from", "to");

INSERT INTO g("from", "to") VALUES
  ('A', 'B'),
  ('B', 'A'),
  ('B', 'C'),
  ('A', 'D');

TABLE g;

SELECT DISTINCT "from", "to2" AS "to"
FROM (SELECT DISTINCT *
      FROM   (TABLE g) AS _,
             (SELECT DISTINCT "from" AS "from2", "to" AS "to2"
              FROM   (TABLE g) AS _) AS __
      WHERE  "to" = "from2") AS _;
