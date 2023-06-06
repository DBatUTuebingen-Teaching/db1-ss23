-- Demonstrate the use of foreign keys in the LEGO mini-world

-- ⚠️ Connect to a scratch database, don't ruin your original LEGO database
\c scratch

-- Create LEGO schema, make it the default
CREATE SCHEMA IF NOT EXISTS lego;
SET SCHEMA 'lego';

-- Prepare/clean-up from earlier runs
DROP TABLE IF EXISTS bricks CASCADE;
DROP TABLE IF EXISTS minifigs CASCADE;
DROP TABLE IF EXISTS categories CASCADE;


-- Create mini-world specific domains (and thus types)
DROP DOMAIN IF EXISTS id;
DROP DOMAIN IF EXISTS rgb;
DROP DOMAIN IF EXISTS type;

CREATE DOMAIN id AS
  character varying(20);

CREATE DOMAIN rgb AS text
  CHECK (VALUE ~ '^(\d|[a-f]){6}$');

CREATE DOMAIN type AS character(1)
  CHECK (VALUE IN ('B', 'M'));


-- Create bricks, minifigs, categories, colors tables
CREATE TABLE bricks (
  piece  id,
  type   type,
  name   text,
  cat    integer,
  weight real,
  img    text,
  x      real,
  y      real,
  z      real
);

CREATE TABLE minifigs (
  piece  id,
  type   type,
  name   text,
  cat    integer,
  weight real,
  img    text
);

CREATE TABLE categories (
  cat  integer,
  name text
);

-- Constraints

-- Add primary keys
ALTER TABLE bricks
  ADD PRIMARY KEY (piece);

ALTER TABLE minifigs
  ADD PRIMARY KEY (piece);

ALTER TABLE categories
  ADD PRIMARY KEY (cat);


-- Add candidate keys: UNIQUE(...) + NOT NULL
ALTER TABLE bricks
  ALTER COLUMN img SET NOT NULL;
ALTER TABLE bricks
  ADD UNIQUE (img);

ALTER TABLE minifigs
  ALTER COLUMN img SET NOT NULL;
ALTER TABLE minifigs
  ADD UNIQUE (img);


-- Protect us from accidentally inserting 'M'-type bricks
ALTER TABLE bricks
  ADD CHECK (type = 'B');

-- Protect us from accidentally inserting 'B'-type minifigs
ALTER TABLE minifigs
  ADD CHECK (type = 'M');


-- Add foreign keys
ALTER TABLE bricks
  ADD FOREIGN KEY (cat) REFERENCES categories;

ALTER TABLE minifigs
  ADD FOREIGN KEY (cat) REFERENCES categories
  ON DELETE CASCADE
  ON UPDATE SET NULL;  -- CASCADE: propagate update to source


-- Review current table schemata
-- (shows `Foreign-key constraints' and `Referenced by')
\d bricks
\d minifigs
\d categories


-- Populate the tables
-- (NB: the order categories < {bricks, minifigs} matters)
COPY categories(cat, name)
FROM '/Users/grust/DB1/repo/Notes/Week03/categories-no-header.csv';

COPY bricks(piece, type, name, cat, weight, img, x, y, z)
FROM '/Users/grust/DB1/repo/Notes/Week03/bricks-no-header.csv';

COPY minifigs(piece, type, name, cat, weight, img)
FROM '/Users/grust/DB1/repo/Notes/Week03/minifigs-no-header.csv';


-- Attempt violations of referential integrity:

-- (1) Fails: insert source row referencing non-existent category 0
INSERT INTO bricks(piece, type, name, cat, weight, img, x, y, z) VALUES
  ('bogus', 'B', 'Bogus Brick', 0, 42.0, 'http://www.bricklink.com/PL/bogus', 1, 1, 1);

-- (2) Fails: delete a category (referenced from source bricks) from target table
DELETE FROM categories AS c
  WHERE c.name = 'Train';

-- (3) Fails: update the primary key of the referenced 'Train' category in target table
UPDATE categories AS c
SET    cat = 0
WHERE  cat = 124;

-- (4) OK: delete a non-referenced category from target table
DELETE FROM categories AS c
  WHERE c.name = 'Toy Story';

-- (5) OK, but CASCADES to minifigs: delete a referenced category from target table

-- before (count number of rows in minifigs)
SELECT COUNT(*)
FROM   minifigs;

DELETE FROM categories AS c
  WHERE c.name = 'Hobbit and Lord of the Rings';

-- after
SELECT COUNT(*)
FROM   minifigs;

-- (6) OK, but propagates UPDATE to minifigs:
--     set foreign key to NULL in referencing source rows

-- before (0 rows)
SELECT m.*
FROM   minifigs AS m
WHERE  m.cat IS NULL;

UPDATE categories AS c
SET    cat = 999
WHERE  c.name = 'Indiana Jones';

-- after (44 rows)
SELECT m.*
FROM   minifigs AS m
WHERE  m.cat IS NULL;
