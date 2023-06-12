-- Simulating functions over nested tables (in 1NF representation)

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
  (3, 'cross',    3),
  (4, 'empty',    4),
  (5, 'rect',     1);

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




-- (1) Shapes with no drawing commands
-- NF²:
-- SELECT s.id, s.shape
-- FROM   shapes AS s
-- WHERE  EMPTY(s.turtle);

SELECT s.id, s.shape
FROM   shapes AS s
WHERE  NOT EXISTS (SELECT 1
                   FROM   turtles AS t
                   WHERE  s.turtle = t.turtle);

SELECT s.id, s.shape
FROM   shapes AS s
WHERE  s.turtle NOT IN (SELECT DISTINCT t.turtle
                        FROM   turtles AS t);



-- (2) Shapes drawn with the pen down all the time
-- NF²:
-- SELECT s.id, s.shape
-- FROM   shapes AS s
-- WHERE  FORALL c IN s.turtle: (c.command).down
--
--   ≡
--
-- SELECT s.id, s.shape
-- FROM   shapes AS s
-- WHERE  NOT EXISTS c IN s.turtle: NOT((c.command).down)


SELECT s.id, s.shape
FROM   shapes AS s
WHERE  NOT EXISTS (SELECT 1
                   FROM   turtles AS t
                   WHERE  t.turtle = s.turtle
                   AND    NOT((t.command).down));





-- (3) Shapes that contain strokes of length > 10
-- NF²:
-- SELECT s.id, s.shape
-- FROM   shapes AS s
-- WHERE  EXISTS c IN s.turtle: sqrt(c.command.x^2 + c.command.y^2) > 10


SELECT s.id, s.shape
FROM   shapes AS s
WHERE  EXISTS (SELECT 1
               FROM   turtles AS t
               WHERE  t.turtle = s.turtle
               AND    sqrt(((t.command).x)^2 + ((t.command).y)^2) > 10);



-- (4) First drawing command of any shape
-- NF²:
-- SELECT s.id, s.shape, s.turtle[1].command AS head
-- FROM   shapes AS s;
--
-- NB: handling of shape `empty'!

SELECT s.id, s.shape, (SELECT t.command
                       FROM   turtles AS t
                       WHERE  t.pos = 1
                       AND    t.turtle = s.turtle) AS head
FROM   shapes AS s;


-- This variant will omit shape `empty' from the result :-(
-- (not the original intent of the NF² query)
SELECT s.id, s.shape, t.command AS head
FROM   shapes AS s, turtles AS t
WHERE  s.turtle = t.turtle
AND    t.pos = 1;


-- (5) Length of list of drawing commands
-- NF²:
-- SELECT s.id, s.shape, LENGTH(s.turtle) AS length
-- FROM   shapes s;
--
-- NB: handling of shape `empty'!

SELECT s.id, s.shape, (SELECT COUNT(*)
                       FROM   turtles AS t
                       WHERE  t.turtle = s.turtle) AS head
FROM   shapes AS s;

