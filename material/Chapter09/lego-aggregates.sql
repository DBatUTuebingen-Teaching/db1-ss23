-- Demonstrate the use of GROUP BY and aggregates on the LEGO set

\c lego
set schema 'lego';


SELECT max(s.weight)                 AS "max",
       min(s.weight)                 AS "min",
       avg(s.weight)                 AS avg1,
       sum(s.weight)/count(s.weight) AS avg2
FROM   sets AS s;


-- What is the set with largest piece count?

\d contains

-- Intermediate result:
-- LEGO sets and their size (= piece counts)
SELECT c.set, sum(c.quantity) AS size  -- ⚠️ nesting aggregates (max(sum(...))) makes no sense
FROM   contains AS c
WHERE  NOT c.extra
GROUP BY c.set;


WITH
sizes(set, size) AS (
  SELECT c.set, sum(c.quantity) AS size
  FROM   contains AS c
  WHERE  NOT c.extra
  GROUP BY c.set
)
SELECT s1.set, s.name, s1.size
FROM   sizes AS s1, sets AS s
WHERE  s1.size = (SELECT max(s2.size)
                  FROM   sizes AS s2)
AND    s1.set = s.set;


-- Result:
-- +---------+-----------+------+
-- |   set   |   name    | size |
-- +---------+-----------+------+
-- | 10189-1 | Taj Mahal | 5922 |
-- +---------+-----------+------+
--
-- Also see http://www.youtube.com/watch?v=TudW-8FjMzE
-- From the YouTube entry:
-- Q: ``An animated (computer rendered) build of Lego set 10189 -
--      the Taj Mahal. The largest number of pieces in any Lego
--      set to date at 5922 pieces ?''
--
-- A: Yes!



---------------------------------------------------------------------

-- Alternative formulation (without max() aggregate):
-- set s1 has maximum size if there does NOT EXIST a set s2 with larger size

WITH
sizes(set, size) AS (
  SELECT c.set, sum(c.quantity) AS size
  FROM   contains AS c
  WHERE  NOT c.extra
  GROUP BY c.set
)
SELECT s1.set, s.name, s1.size
FROM   sizes AS s1, sets AS s
WHERE  NOT EXISTS(SELECT 1
                  FROM   sizes AS s2
                  WHERE  s2.size > s1.size)
AND    s1.set = s.set;



---------------------------------------------------------------------

-- What are the heaviest LEGO sets?

WITH
weights(set, weight) AS (
  SELECT c.set, sum(c.quantity * b.weight) AS weight
  FROM   contains AS c, bricks AS b
  WHERE  NOT c.extra
  AND    c.piece = b.piece
  GROUP BY c.set
)
SELECT s.set, s.name, w.weight
FROM   weights AS w, sets AS s
WHERE  w.set = s.set
AND    w.weight IS NOT NULL
ORDER BY w.weight DESC
LIMIT 10;


-- Result:
--
-- ...
-- ┌─────────┬───────────────────────────────┬────────────────────┐
-- │   set   │             name              │       weight       │
-- ├─────────┼───────────────────────────────┼────────────────────┤
-- │ 9020-1  │ LEGO Soft Starter Set         │               7380 │
-- │ 4785-1  │ Black Castle                  │  5680.829963445663 │
-- │ 10030-1 │ Imperial Star Destroyer - UCS │  5594.059985548258 │
-- │ 9090-1  │ Large Duplo Basic Set         │  5145.289964199066 │
-- │ 3450-1  │ Statue of Liberty             │ 5040.5399704277515 │
-- │ 10189-1 │ Taj Mahal                     │   4911.00999955833 │
-- │ 9021-1  │ Medium set of Soft Bricks     │             4612.5 │
-- │ 3290-1  │ The Big Family House          │ 4408.6899994164705 │
-- │ 10143-1 │ Death Star II                 │ 4356.3599997237325 │
-- │ 9452-1  │ Giant Lego Topic Set          │  4217.879993259907 │
-- └─────────┴───────────────────────────────┴────────────────────┘
