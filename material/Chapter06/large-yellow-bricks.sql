-- Demonstrates the use of common table expressions (WITH)

\c lego
SET SCHEMA 'lego';

-- Find the large yellow bricks in the LEGO catalogue
-- (1) Find all yellow-ish colors (→ yellows)
-- (2) Find all large bricks (→ large_bricks)
-- (3) Relate tables yellows and large_bricks (via available_in)

-- Join graph:
--
--       ( large_bricks )----( avaiable_in )----( yellows )

WITH
yellows(color) AS (                                 -- (1)
  SELECT c.color
  FROM   colors AS c
  WHERE  c.name ~ 'Yellow'
),
large_bricks(brick, name, weight) AS (              -- (2)
  SELECT b.piece, b.name, b.weight
  FROM   bricks AS b
  WHERE  b.x > 10 AND b.y > 10
  AND    NOT (b.name ~ 'Sticker|Paper')
)
SELECT lb.name, lb.weight                           -- (3)
FROM   large_bricks AS lb, yellows AS y, available_in AS ai
WHERE  lb.brick = ai.brick AND ai.color = y.color;





-- Equivalent formulation without common table expression (WITH):
--
SELECT lb.name, lb.weight
FROM   (SELECT b.piece AS brick, b.name, b.weight
        FROM   bricks AS b
        WHERE  b.x > 10 AND b.y > 10
        AND    NOT (b.name ~ 'Sticker|Paper')) AS lb,
       (SELECT c.color
        FROM   colors AS c
        WHERE  c.name ~ 'Yellow') AS y,
       available_in AS ai
WHERE  lb.brick = ai.brick AND ai.color = y.color;
