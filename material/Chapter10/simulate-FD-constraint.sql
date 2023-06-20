-- Use a SQL rewrite rule to simulate a non-key FD constraint

-- ⚠️ This is a SQL anti-pattern: do not rely on inefficient
--    triggers to check FDs.  Instead, improve the design of
--    your tables (e.g., convert into BCNF).

\c scratch

DROP TABLE IF EXISTS users CASCADE;

-- Create a table of users and their ratings (of movies, music, podcasts, ...)

CREATE TABLE users (
  name   text,
  rating integer,
  stars  text
);

-- Constraint: each user may give one rating only
ALTER TABLE users
  ADD PRIMARY KEY (name);

-- Constraint rating1to5: rating ∈ [1...5]
ALTER TABLE users
  ADD CONSTRAINT rating1to5 CHECK (1 <= rating AND rating <= 5);

-- table materializes the function stars = f(rating)
INSERT INTO users VALUES
  ('Alex', 3, '***'  ),
  ('Bert', 1, '*'    ),
  ('Cora', 4, '****' ),
  ('Drew', 5, '*****'),
  ('Erik', 1, '*'    ),
  ('Fred', 3, '***'  );


-- Would like to protect the FD rating → stars
--
-- Wishful SQL DML thinking:
--
--   ALTER TABLE users
--     ADD FUNCTIONAL DEPENDENCY (rating) DETERMINES stars


-- Simulate the FD using PostgreSQL's triggers

-- (⚠️ This is *not* the recommend solution:
--     improve the table design of users instead.)


CREATE OR REPLACE FUNCTION users_FD_rating_stars() RETURNS trigger AS
$$
  BEGIN
    IF (EXISTS (SELECT 1
                FROM   (TABLE users UNION ALL VALUES (new.*)) AS u
                GROUP BY u.rating
                HAVING count(DISTINCT u.stars) > 1))
      THEN BEGIN
              RAISE NOTICE 'FD rating ￫ stars in users would be violated!';
              RETURN NULL;   -- do nothing!
           END;
      ELSE RETURN new;
    END IF;
  END;
$$ LANGUAGE PLPGSQL;

CREATE TRIGGER users_FD_rating_stars
BEFORE INSERT OR UPDATE ON users
FOR EACH ROW
  EXECUTE PROCEDURE users_FD_rating_stars();


-- These two FD-violating updates will now do nothing instead:

INSERT INTO users(name, rating, stars) VALUES
  ('Herb', 4, '**');

UPDATE users AS u
SET stars = '**********'
WHERE u.name = 'Alex';

TABLE users;
