\c scratch

-- Demonstrate the use of correlation (here: in the SELECT clause)

DROP TABLE IF EXISTS users;

-- Create a table of users and their ratings (of movies, music, podcasts, ...)

CREATE TABLE users (
  name   text,
  rating integer
);

-- Constraint: each user may give one rating only
ALTER TABLE users
  ADD PRIMARY KEY (name);

-- Constraint rating1to5: rating ∈ [1...5]
ALTER TABLE users
  ADD CONSTRAINT rating1to5 CHECK (1 <= rating AND rating <= 5);

INSERT INTO users VALUES
  ('Alex', 5),
  ('Bert', 1),
  ('Cora', 4);

TABLE users;

-- List ratings but translate rating into sequence of `*'
EXPLAIN ANALYZE
SELECT  u.name, (SELECT s.stars
                   FROM (VALUES (1, '*'    ),
                                (2, '**'   ),
                                (3, '***'  ),
                                (4, '****' ),
                                (5, '*****')) AS s(rating, stars)
                 WHERE  s.rating = u.rating) AS stars
--                                 ^^^^^^^^ correlation!
FROM   users AS u;


-- Dropping the constraint and modifying one rating to exceed the [1...5] scale
ALTER TABLE users
  DROP CONSTRAINT rating1to5;

UPDATE users AS u
SET    rating = 10
WHERE  u.name = 'Alex';

TABLE users;

SELECT  u.name, (SELECT s.stars
                   FROM (VALUES (1, '*'    ),
                                (2, '**'   ),
                                (3, '***'  ),
                                (4, '****' ),
                                (5, '*****')) AS s(rating, stars)
                 WHERE  s.rating = u.rating) AS stars
FROM   users AS u;


-- Observation: table s(rating, stars) materializes the computable
-- Pg string function repeat(rating, '*').  Replace table with
-- function.  This still uses correlation in the SELECT clause!


SELECT u.name, repeat('*', u.rating) AS stars
--                         ^^^^^^^^ correlation!
FROM   users AS u;


-- Demonstrate the use of correlation (here: in the WHERE clause)

\c lego
SET SCHEMA 'lego';

-- Find all LEGO bricks whose category is related to animals
SELECT b.name, b.cat                     -- NB: cannot access c.cat here!
FROM   bricks AS b
WHERE  (SELECT c.name
        FROM   categories AS c
        WHERE  b.cat = c.cat) ~ 'Animal';




-- An alternative, equivalent formulation based on an equi-join
SELECT b.name, b.cat
FROM   bricks AS b, categories AS c
WHERE  b.cat = c.cat
AND    c.name ~ 'Animal';
