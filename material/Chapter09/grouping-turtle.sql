-- Demonstrate the use of GROUP BY to operate on the lists of
-- turtle drawing commands


DROP TABLE IF EXISTS shapes CASCADE;
DROP TABLE IF EXISTS turtles CASCADE;

-- A surrogate type that stands in for a nested table
DROP DOMAIN IF EXISTS surrogate;
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

-- Insertion of two additional shapes into NF² table shapes:
-- - shape empty: empty nested table of drawing commands
-- - shape rect:  same drawing commands as for shape square

INSERT INTO shapes(id, shape, turtle) VALUES
  (4, 'empty', 4),          -- a surrogate value *not* occuring in table turtles
  (5, 'rect',  1);          -- re-using the surrogate value of shape square


TABLE shapes;
TABLE turtles;

---------------------------------------------------------------------

-- Variant ➊: Length of drawing command lists for each shape
SELECT t.turtle, count(*) AS length
FROM   turtles AS t
GROUP BY t.turtle;




-- Variant ➋: Length of drawing command lists for each shape
--             (columns turtle|shape|length, result includes empty, rect)

SELECT s.id AS turtle, s.shape, (SELECT count(*)
                                 FROM   turtles AS t
                                 WHERE  s.turtle = t.turtle) AS length
FROM   shapes AS s;




-- Length of stroke path for each shape
SELECT t.turtle, sum(sqrt((t.command).x * (t.command).x +
                          (t.command).y * (t.command).y)) AS path_length
FROM   turtles AS t
GROUP BY t.turtle;




-- Which shapes have a closed path?
SELECT s.shape
FROM   (SELECT t1.turtle, sum((t1.command).x) AS Δx, sum((t1.command).y) AS Δy
        FROM   turtles AS t1
        GROUP BY t1.turtle) AS t2,
       shapes AS s
WHERE  t2.Δx = 0
AND    t2.Δy = 0
AND    t2.turtle = s.turtle;




-- Which shapes are draw in multiple strokes (pen up at least once)?
SELECT s.shape
FROM   (SELECT t1.turtle, bool_and((t1.command).down) AS all_down
        FROM   turtles AS t1
        GROUP BY t1.turtle) AS t2,
       shapes AS s
WHERE  NOT t2.all_down
AND    t2.turtle = s.turtle;



----------------------------------------------------------------------------

-- Use GROUP BY to recreate the shapes table as shown
-- in the "Arrays in Table Cells" section

-- NB: shape `empty' not included

SELECT s.id, s.shape, array_agg(t.command ORDER BY t.pos) AS turtle
FROM   shapes AS s, turtles AS t
WHERE  s.turtle = t.turtle
GROUP BY s.id, s.shape;


-- NB: this includes shape `empty'

SELECT s.id, s.shape, (SELECT array_agg(t.command ORDER BY t.pos)
                       FROM   turtles AS t
                       WHERE  s.turtle = t.turtle) AS turtle
FROM   shapes AS s;


----------------------------------------------------------------------------

-- NB: Not related to GROUP BY (shown here for completeness)


-- Translate all the way back to the shapes table as shown
-- in the "Structured Text in Table Cells" section

SELECT s.id, s.shape,
       array_to_string((SELECT array_agg(array_to_string(ARRAY[CASE WHEN (t.command).down
                                                                    THEN 'd'
                                                                    ELSE 'u'
                                                               END,
                                                               (t.command).x :: text,
                                                               (t.command).y :: text],
                                                         ',')
                                        ORDER BY t.pos)
                        FROM   turtles AS t
                        WHERE  s.turtle = t.turtle),
                       '; ') turtle
FROM   shapes AS s;
