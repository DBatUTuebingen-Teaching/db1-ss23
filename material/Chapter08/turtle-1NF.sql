-- Demonstrate the encoding of lists in terms of a table bundle
-- (resulting from NF² to 1NF conversion), tied together via a surrogate column

DROP TABLE IF EXISTS shapes CASCADE;
DROP TABLE IF EXISTS turtles CASCADE;

-- A surrogate type that stands in for a nested table
DROP TYPE IF EXISTS surrogate;
CREATE DOMAIN surrogate integer NOT NULL;

-- Create a type to represent a turtle drawing command
DROP TYPE IF EXISTS cmd;
CREATE TYPE cmd AS (
  down boolean,       -- is the pen down?
  x    integer,       -- move right x units (x < 0: left)
  y    integer        -- move up y units (y < 0: down)
);

CREATE TABLE shapes (
  id     integer,
  shape  text,         -- name of shape
  turtle surrogate     -- (surrogate for a) table of drawing commands
);

ALTER TABLE shapes
  ADD PRIMARY KEY (id);

ALTER TABLE shapes
  ALTER shape SET NOT NULL;

ALTER TABLE shapes
  ADD UNIQUE (shape);


CREATE TABLE turtles (
  turtle  surrogate,
  pos     integer,
  command cmd
);

ALTER TABLE turtles
  ADD PRIMARY KEY (turtle, pos);

ALTER TABLE turtles
  ALTER command SET NOT NULL;

-- Populate outer table
INSERT INTO shapes(id, shape, turtle) VALUES
  (1, 'square',   1),
  (2, 'triangle', 2),
  (3, 'cross',    3);

-- Populate the table of drawing commands
INSERT INTO turtles(turtle, pos, command) VALUES
  (1, 1, (true,  0, 10)),  -- "nested table" for shape square
  (1, 2, (true, 10,  0)),
  (1, 3, (true,  0,-10)),
  (1, 4, (true,-10,  0)),

  (2, 1, (true,  5, 10)),  -- "nested table" for shape triangle
  (2, 2, (true,  5,-10)),
  (2, 3, (true,-10,  0)),

  (3, 1, (true,   0, 10)),  -- "nested table" for shape cross
  (3, 2, (false, -5, -5)),
  (3, 3, (true,  10,  0));

TABLE shapes;
TABLE turtles;


SELECT s.id, s.shape, t.pos, t.command
FROM   shapes AS s, turtles AS t
WHERE  s.turtle = t.turtle
AND    s.shape = 'square';


-----------------------------------------------------------------------







-- Insertion of two additional shapes into NF² table shapes:
-- - shape empty: empty nested table of drawing commands
-- - shape rect:  same drawing commands as for shape square

INSERT INTO shapes(id, shape, turtle) VALUES
  (4, 'empty', 4),          -- a surrogate value *not* occuring in table turtles
  (5, 'rect',  1);          -- re-using the surrogate value of shape square



-----------------------------------------------------------------------


-- Find the shapes where the pen is up at least once ("multiple strokes")

-- NF²:
-- SELECT s.id, s.shape
-- FROM   shapes AS s
-- WHERE  EXISTS (SELECT 1
--                FROM   s.turtle AS c
--                WHERE  NOT (c.command).down);

SELECT s.id, s.shape
FROM   shapes AS s
WHERE  EXISTS (SELECT 1
               FROM   (SELECT t.*                        -- ⎫ translation of
                       FROM   turtles t                  -- ⎬ expression
                       WHERE  t.turtle = s.turtle) AS c  -- ⎭ s.turtle
               WHERE   NOT (c.command).down);


-- The innermost SQL query can be unnested and merged with its enclosing query
SELECT s.id, s.shape
FROM   shapes AS s
WHERE  EXISTS (SELECT 1
               FROM   turtles AS t
               WHERE  t.turtle = s.turtle
               AND    NOT (t.command).down);



-----------------------------------------------------------------------
-- Render a shape using the HTML5 canvas
--
-- 1. Cut & paste the output of the following query into `shape.html'
-- 2. Open `shape.html' in a web browser


-- Remove table borders and headers (makes the output of the following
-- query cut&paste-able)
\pset format unaligned
\pset tuples_only on

WITH RECURSIVE
  -- Drawing commands for shape using *absolute* canvas coordinates
  drawing(shape, pos, down, x, y) AS (
    SELECT s.shape, 0 pos, false down, 100 x, 100 y
    FROM   shapes s
      UNION ALL
    SELECT d.shape, t.pos, (t.command).down, 10 * (t.command).x + d.x, 10 * (t.command).y + d.y
    FROM   drawing d, shapes s, turtles t
    WHERE  d.shape = s.shape
    AND    s.turtle = t.turtle
    AND    t.pos = d.pos + 1
  )
  ,
  -- Turn drawing commands into JavaScript lineTo/moveTo statements
  -- that can draw onto the HTML5 canvas (one array of statements
  -- per shape)
  javascript(shape, statements) AS (
    SELECT d.shape,
           array_agg(format('ctx.%s(%s,%s);',
                            CASE WHEN d.down THEN 'lineTo' ELSE 'moveTo' END,
                            d.x,
                            d.y)
                     ORDER BY d.pos) statements
    FROM   drawing d
    GROUP BY d.shape
  )
  ,
  -- Embed JavaScript statements into minimal HTML5 template
  html5(shape, code) AS (
    SELECT js.shape,
           ARRAY['<!DOCTYPE html>',
                 '<html>',
                 '<body>',
                 '<canvas id="canvas" width="200" height="200"/>',
                 '<script>',
                 'var ctx = document.getElementById("canvas").getContext("2d");']
              || js.statements ||
           ARRAY['ctx.stroke();',
                 '</script>',
                 '</body>',
                 '</html>'] code
    FROM   javascript js
  )
SELECT unnest(h.code)
FROM   html5 h
WHERE  h.shape = 'triangle';  --  shape to render


\pset format aligned
\pset tuples_only off
