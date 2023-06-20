-- Demonstrate corner cases for grouping and aggregation,
-- related to the treatment of empty row sets and the presence of NULLs

-- Create and populate sample table
DROP TABLE IF EXISTS R;

CREATE TABLE R (
  G boolean,
  A integer
);

INSERT INTO R(G,A) VALUES
  (true,     1),
  (true,     2),
  (true,  NULL),
  --------------
  (false, NULL),
  (false, NULL),
  --------------
  (NULL,     3),
  (NULL,     4);

TABLE R
ORDER BY G;

-----------------------------------------------------------------------

-- ➊ Aggregations over the empty row set yield
--    - 0    for count(*), count(‹expression›)
--    - NULL for all other aggregation functions (including sum()!):

SELECT count(*)   AS "# of rows",
       count(r.A) AS "count(A)",
       sum(r.A),
       array_agg(r.A ORDER BY r.A)
FROM   R AS r
WHERE  false;


-- ➋ All rows that yield NULL for a grouping expression form one group

SELECT r.G,
       count(*) AS "# of rows"
FROM   R AS r
GROUP BY r.G;


-- ➌ All aggregation functions (except count(*) and array_agg())
--   ignore NULL values. If a group contains all NULL values,
--   see ➊ above.

SELECT r.G,
       count(*)   AS "# of rows",
       count(r.A) AS "count(A)",
       sum(r.A),
       avg(r.A),
       array_agg(r.A ORDER BY r.A DESC NULLS LAST)  -- ORDER BY ... [ASC|DESC] [NULLS FIRST|NULLS LAST]
FROM   R AS r
GROUP BY r.G;

-- Result:
--
-- ┌───┬───────────┬──────────┬─────┬────────────────────┬─────────────┐
-- │ g │ # of rows │ count(A) │ sum │        avg         │  array_agg  │
-- ├───┼───────────┼──────────┼─────┼────────────────────┼─────────────┤
-- │ f │         2 │        0 │   ▢ │                  ▢ │ {NULL,NULL} │
-- │ t │         3 │        2 │   3 │ 1.5000000000000000 │ {1,2,NULL}  │
-- │ ▢ │         2 │        2 │   7 │ 3.5000000000000000 │ {3,4}       │
-- └───┴───────────┴──────────┴─────┴────────────────────┴─────────────┘
