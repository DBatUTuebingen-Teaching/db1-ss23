-- Demonstrate the encoding of lists in terms of arrays

\c scratch

DROP TABLE IF EXISTS shapes CASCADE;

-- Create a type to represent a turtle drawing command
DROP TYPE IF EXISTS cmd CASCADE;

CREATE TYPE cmd AS (
  down boolean,       -- is the pen down?
  x    integer,       -- move right x units (x < 0: left)
  y    integer        -- move up y units (y < 0: down)
);

CREATE TABLE shapes (
  id     integer,
  shape  text,         -- name of shape
  turtle cmd[]         -- array of drawing commands
);

ALTER TABLE shapes
  ADD PRIMARY KEY (id);

ALTER TABLE shapes
  ALTER shape SET NOT NULL;

ALTER TABLE shapes
  ADD UNIQUE (shape);

INSERT INTO shapes(id, shape, turtle) VALUES
  (1, 'square',   ARRAY[(true,0,10) :: cmd, (true,10,0) :: cmd, (true,0,-10) :: cmd, (true,-10,0) :: cmd]),
  (2, 'triangle', ARRAY[(true,5,10) :: cmd, (true,5,-10) :: cmd, (true,-10,0) :: cmd]),
  (3, 'cross',    ARRAY[(true,0,10) :: cmd, (false,-5,-5) :: cmd, (true,10,0) :: cmd]);

TABLE shapes;


-- (1) unnest() turns its array argument into a table of rows (here: of type cmd)
SELECT pxy.*
FROM   unnest((SELECT s.turtle
               FROM   shapes AS s
               WHERE  s.shape = 'square')) AS pxy;


---------------------------------------------------------------------

-- List all PostgreSQL array types t[] (named '_t' internally)

SELECT t1.typname, t1.typcategory
FROM   pg_type AS t1
WHERE  t1.typcategory = 'A'        -- 'A': array type
ORDER BY t1.typname;
