-- ⚠️ Connect to the scratch copy of your LEGO database
-- (created by foreign-keys.sql), don't ruin your original LEGO database
\c scratch
SET SCHEMA 'lego';


-- (1) ---------------------------------------------------------------------

-- A referential integrity check:
SELECT EXISTS(SELECT 1
              FROM   bricks AS b
              WHERE  b.cat NOT IN (SELECT c.cat
                                   FROM   categories AS c)) AS "Referential integrity violated?";

SELECT DISTINCT 'Referential integrity violated!'
FROM   bricks AS b
WHERE  b.cat NOT IN (SELECT c.cat
                     FROM   categories AS c);

-- name of foreign key constraint in table bricks?
\d bricks

-- Disable foreign key constraint so we can violate referential integrity (har har)
ALTER TABLE bricks
  DROP CONSTRAINT IF EXISTS bricks_cat_fkey;

-- ⚠️ Danger Zone: Referential integrity not protected

-- Remove a referenced target row, thus violating referential integrity
DELETE FROM categories AS c
WHERE c.cat = 439 AND c.name = 'Soft Bricks';

-- Referential integrity check again:
SELECT EXISTS(SELECT 1
              FROM   bricks AS b
              WHERE  b.cat NOT IN (SELECT c.cat
                                   FROM   categories AS c)) AS "Referential integrity violated?";

SELECT DISTINCT 'Referential integrity violated!'
FROM   bricks AS b
WHERE  b.cat NOT IN (SELECT c.cat
                     FROM   categories AS c);

-- ⚠️ End Danger Zone

INSERT INTO categories(cat, name) VALUES
  (439, 'Soft Bricks');

-- Re-establish foreign key constraint
ALTER TABLE bricks
  ADD FOREIGN KEY (cat) REFERENCES categories;


-- (2) ---------------------------------------------------------------------

-- Find those non-referenced categories that may be removed without violation of
-- referential integrity

SELECT c.*
FROM   categories AS c
WHERE  c.cat NOT IN (SELECT b.cat
                     FROM   bricks AS b);


-- We can delete these categories without violating referential integrity:
DELETE FROM categories AS c
WHERE c.cat NOT IN (SELECT b.cat
                    FROM   bricks AS b);


-- Referential integrity check again:
SELECT EXISTS(SELECT 1
              FROM   bricks AS b
              WHERE  b.cat NOT IN (SELECT c.cat
                                   FROM   categories AS c)) AS "Referential integrity violated?";

SELECT DISTINCT 'Referential integrity violated!'
FROM   bricks AS b
WHERE  b.cat NOT IN (SELECT c.cat
                     FROM   categories AS c);



-- Epilogue -----------------------------------------------------------------

-- Make sure that table categories contains the original data
-- (above we have messed with it)

ALTER TABLE bricks
  DROP CONSTRAINT IF EXISTS bricks_cat_fkey;
ALTER TABLE minifigs
  DROP CONSTRAINT IF EXISTS minifigs_cat_fkey;

TRUNCATE categories;
COPY categories(cat, name)
  FROM '/Users/grust/DB1/repo/Notes/Week03/categories-no-header.csv';

-- Re-establish foreign key constraints
ALTER TABLE bricks
  ADD FOREIGN KEY (cat) REFERENCES categories;
ALTER TABLE minifigs
  ADD FOREIGN KEY (cat) REFERENCES categories;

