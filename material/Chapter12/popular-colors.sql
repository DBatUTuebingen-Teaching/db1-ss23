-- Demonstrate the use of left outer join in combination with grouping/aggregation

-- Query:
-- List *all* colors ordered by their popularity (= number of bricks available in that color)

\c lego

set schema 'lego';


-- Inspect intermediate result after left outer join
--
-- SELECT c.name, c.finish, a.brick
-- FROM   colors AS c NATURAL LEFT OUTER JOIN available_in AS a;




-- (1) Formulation with left outer join:
--     NB: COUNT({NULL, ..., NULL}) = 0

SELECT c.name, c.finish, COUNT(a.brick) AS popularity
FROM   colors AS c NATURAL LEFT OUTER JOIN available_in AS a
GROUP BY c.color
ORDER BY popularity DESC, name ASC;




-- (2) Formulation w/o alternative SQL join syntax:

SELECT c.name, c.finish, COUNT(a.brick) AS popularity
FROM   colors AS c, available_in AS a                         -- ⎱ colors ⋈ available_in
WHERE  c.color = a.color                                      -- ⎰
GROUP BY c.color
  --
  UNION ALL                                                   --  ∪
  --
SELECT c.name, c.finish, 0 AS popularity                      -- ⎫
FROM   colors AS c                                            -- ⎬ (colors ▷ available_in) × {(popularity:0)}
WHERE  c.color NOT IN (SELECT a.color FROM available_in AS a) -- ⎭
  --
ORDER BY popularity DESC, name ASC;
