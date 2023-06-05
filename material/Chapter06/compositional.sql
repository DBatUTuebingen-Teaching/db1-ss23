-- Switch over to the LEGO database
\c lego
SET SCHEMA 'lego';

-- Problem: Which sets contain the brick 'Wedge 3 x 2 Right'?

-- Two-step approach:

-- (1) Translate brick name into piece ID
SELECT b.piece
FROM   bricks AS b
WHERE  b.name = 'Wedge 3 x 2 Right';

-- Yields single-row single-column table:
-- +-------+
-- | piece |
-- +-------+
-- | 6564  |
-- +-------+

-- (2) Use piece ID to find the wanted LEGO sets
SELECT c.set
FROM   contains AS c
WHERE  c.piece = '6564';




-- One-step approach, based on query nesting in the WHERE clause (compositionality):
SELECT c.set
FROM   contains AS c
WHERE  c.piece = (SELECT b.piece
                  FROM   bricks AS b
                  WHERE  b.name = 'Wedge 3 x 2 Right');


-- Improvement: get human-readable set name from sets table
--
--       Table "lego.sets"
-- +--------+---------+-----------+
-- | Column |  Type   | Modifiers |
-- +--------+---------+-----------+
-- | set    | id      | not null  |
-- | name   | text    |           | <--
-- | cat    | integer |           |
-- | x      | real    |           |
-- | y      | real    |           |
-- | z      | real    |           |
-- | weight | real    |           |
-- | year   | integer |           |
-- | img    | text    |           |
-- +--------+---------+-----------+

SELECT c.set, s.name
FROM   contains AS c, sets AS s
WHERE  c.piece = (SELECT b.piece
                  FROM   bricks AS b
                  WHERE  b.name = 'Wedge 3 x 2 Right')
AND    c.set = s.set;


-- Improvement: list each distinct set only once

SELECT DISTINCT c.set, s.name
FROM   contains AS c, sets AS s
WHERE  c.piece = (SELECT b.piece
                  FROM   bricks AS b
                  WHERE  b.name = 'Wedge 3 x 2 Right')
AND    c.set = s.set;



-- In an expression, a subquery that yields no rows is interpreted as NULL:

SELECT (SELECT b.piece               -- no piece of this name in LEGO database
        FROM   bricks AS b
        WHERE  b.name = 'Tile 1000 x 1000') AS zero;


-- In an expression, a subquery that yields more than one row
-- leads to a runtime error (bad!):

SELECT (SELECT b.piece               -- 2 pieces of this name in LEGO database
        FROM   bricks AS b           -- (i.e. column name is not a key in bricks)
        WHERE  b.name = 'Wheel 43.2mm D. x 18mm') AS multiple;

-- ERROR:  more than one row returned by a subquery used as an expression
