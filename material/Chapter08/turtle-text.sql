-- Demonstrate the (bad practice of) encoding structured information in
-- columns of type text (here: Logo-style turtle drawing commands)

\c scratch

DROP TABLE IF EXISTS shapes CASCADE;

CREATE TABLE shapes (
  id     integer,
  shape  text,       -- name of shape
  turtle text        -- string-encoded list of drawing commands '<p>,<x>,<y>;...'
);

ALTER TABLE shapes
  ADD PRIMARY KEY (id);

ALTER TABLE shapes
  ALTER shape SET NOT NULL;

ALTER TABLE shapes
  ADD UNIQUE (shape);

-- Create some basic shapes
INSERT INTO shapes(id, shape, turtle) VALUES
  (1, 'square',   'd,0,10; d,10,0; d,0,-10; d,-10,0'),
  (2, 'triangle', 'd,5,10; d,5,-10; d,-10,0'        ),
  (3, 'cross',    'd,0,10; u,-5,-5; d,10,0'         );


TABLE shapes;


-- (1) Split turtle command list for shape 'square' into '<p>,<x>,<y>' command strings
SELECT pxy
FROM   regexp_split_to_table((SELECT s.turtle
                              FROM   shapes AS s
                              WHERE  s.shape = 'square'),
                              E';\\s*') AS pxy;







-- (2) Split command string '<p>,<x>,<y>' into array {'<p>', '<x>', '<y>'}
SELECT regexp_matches(pxy, E'([du]),(-?\\d+),(-?\\d+)') AS pxy
FROM   regexp_split_to_table((SELECT s.turtle
                              FROM   shapes AS s
                              WHERE  s.shape = 'square'),
                              E';\\s*') AS pxy;



-- (3) Turn array {'<p>', '<x>', '<y>'} into individual typed columns
SELECT cmd.pxy[1] = 'd'      AS down,
       cmd.pxy[2] :: integer AS x,
       cmd.pxy[3] :: integer AS y
FROM   (SELECT regexp_matches(pxy, E'([du]),(-?\\d+),(-?\\d+)') AS pxy
        FROM   regexp_split_to_table((SELECT s.turtle
                                      FROM   shapes AS s
                                      WHERE  s.shape = 'square'),
                                     E';\\s*') AS pxy) AS cmd;
