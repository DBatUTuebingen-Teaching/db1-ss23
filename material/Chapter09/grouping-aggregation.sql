--Demonstrate the effect of GROUP BY/aggregate functions

DROP TABLE IF EXISTS R;

CREATE TABLE R (
  G char(1),
  A integer,
  B boolean
);

INSERT INTO R(G,A,B) VALUES
  ('X',    1, true),
  ('X',    2, false),
  ('X',    4, true),

  ('Y',    8, true),
  ('Y',   16, true),

  ('Z',   32, false),
  ('Z', NULL, NULL);


TABLE R;


-- EXPLAIN ANALYZE shows row reduction from 7 to 3
-- (here: PostgreSQL uses sorting to form groups)
-- EXPLAIN ANALYZE
SELECT r.G,
       count(r.A)                  AS "count",
       count(*)                    AS "count*",
       sum(r.A)                    AS "sum",
       avg(r.A)                    AS "avg",
       max(r.A)                    AS "max",
       min(r.A)                    AS "min",
       array_agg(r.A ORDER BY r.A) AS "array",
       bool_and(r.B)               AS "every",
       bool_or(r.B)                AS "some"
FROM   R AS r
GROUP BY r.G;
