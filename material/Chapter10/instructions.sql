-- Generate a table of illustrated LEGO building instructions

\c lego
set schema 'lego';

DROP TABLE IF EXISTS instructions;

CREATE TABLE instructions (
  set      id,             -- this instruction is for this set
  step     integer,        -- instruction step (1, 2, ...)
  piece    id,             -- we need this piece in the step ...
  color    integer,        --   in this color
  quantity integer,        --   and in this quantity
  page     integer,        -- page of instruction booklet
  img      bytea,          -- PNG of instruction schematic
  width    integer,        --   width of PNG
  height   integer         --   and height
);

ALTER TABLE instructions
  ADD PRIMARY KEY (set, step, piece, color);

ALTER TABLE instructions
  ADD FOREIGN KEY (set) REFERENCES sets;

ALTER TABLE instructions
  ADD FOREIGN KEY (piece) REFERENCES bricks;

ALTER TABLE instructions
  ADD FOREIGN KEY (color) REFERENCES colors;

ALTER TABLE instructions
  ADD CHECK (step >= 1);

ALTER TABLE instructions
  ADD CHECK (page >= 1);

ALTER TABLE instructions
  ADD CHECK (width >= 0 AND height >= 0);


-- Image reading ------------------------------------------------------

-- Use PostgreSQL's encode(..., 'base64') built-in function
-- to turn the bitmap's byte array into a base64-encoded string
-- that browsers etc. can display
-- (e.g., see http://base64online.org/decode/)

CREATE EXTENSION IF NOT EXISTS plpython3u;

DROP FUNCTION IF EXISTS read_image(text) CASCADE;

CREATE FUNCTION read_image(img text) RETURNS bytea AS
$$
  try:
    file = open(img, 'rb')
    return file.read()
  except:
    pass

  # could not read file, return NULL
  return None
$$ LANGUAGE plpython3u;

-----------------------------------------------------------------------

-- NB: for your own testing, replace the paths in read_image() with arbitrary images/files/...

INSERT INTO instructions(set, step, piece, color, quantity, page, img, width, height) VALUES
  ('9495-1',  7, '3010',   2, 2, 24, read_image('/‹⚠️ ABSOLUTE PATH TO IMAGE FILES›/instruction-07-9495.png'),  639, 533),
  ('9495-1',  7, '3023',   2, 2, 24, read_image('/‹⚠️ ABSOLUTE PATH TO IMAGE FILES›/instruction-07-9495.png'),  639, 533),
  ('9495-1',  7, '2877',  86, 1, 24, read_image('/‹⚠️ ABSOLUTE PATH TO IMAGE FILES›/instruction-07-9495.png'),  639, 533),
  ('9495-1',  8, '3002',   7, 2, 24, read_image('/‹⚠️ ABSOLUTE PATH TO IMAGE FILES›/instruction-08-9495.png'),  650, 522),
  ('9495-1',  8, '30414',  1, 2, 24, read_image('/‹⚠️ ABSOLUTE PATH TO IMAGE FILES›/instruction-08-9495.png'),  650, 522),
  ('9495-1',  9, '30414', 85, 1, 25, read_image('/‹⚠️ ABSOLUTE PATH TO IMAGE FILES›/instruction-09-9495.png'),  541, 638),
  ('9495-1',  9, '3062b', 85, 2, 25, read_image('/‹⚠️ ABSOLUTE PATH TO IMAGE FILES›/instruction-09-9495.png'),  541, 638),
  ('9495-1', 10, '30033', 11, 1, 25, read_image('/‹⚠️ ABSOLUTE PATH TO IMAGE FILES›/instruction-10-9495.png'),  540, 662),
  ('9495-1', 10, '2412b', 86, 1, 25, read_image('/‹⚠️ ABSOLUTE PATH TO IMAGE FILES›/instruction-10-9495.png'),  540, 662),
  ('9495-1', 10, '4589b', 86, 2, 25, read_image('/‹⚠️ ABSOLUTE PATH TO IMAGE FILES›/instruction-10-9495.png'),  540, 662),
  ('9495-1', 10, '87580', 85, 1, 25, read_image('/‹⚠️ ABSOLUTE PATH TO IMAGE FILES›/instruction-10-9495.png'),  540, 662),
  ('9495-1', 11, '3039',   2, 1, 25, read_image('/‹⚠️ ABSOLUTE PATH TO IMAGE FILES›/instruction-11-9495.png'), 1042, 558),
  ('9495-1', 11, '4073',  85, 4, 25, read_image('/‹⚠️ ABSOLUTE PATH TO IMAGE FILES›/instruction-11-9495.png'), 1042, 558),
  ('9495-1', 11, '44728',  3, 1, 25, read_image('/‹⚠️ ABSOLUTE PATH TO IMAGE FILES›/instruction-11-9495.png'), 1042, 558);


-- review table contents
SELECT i.set, i.step, i.piece, i.color, i.quantity, i.page, i.width, i.height,
       substr(encode(i.img, 'base64'), 1500, 20) AS img
FROM   instructions AS i;



-- Extract the materialized embedded functions from table instructions:

-- 1. printed_on(): maps (set, step) to the page it is printed on

SELECT i.set, i.step, i.page            -- shows redundancy
FROM   instructions AS i;


SELECT DISTINCT i.set, i.step, i.page   -- DISTINCT crucial here: the materialization is redundant!
FROM   instructions AS i
ORDER BY set, step;


-- 2. illustrated_by(): maps (set, step) to its illustration stored in image img

SELECT DISTINCT i.set, i.step, substr(encode(i.img, 'base64'), 1500, 20) AS img
FROM   instructions AS i
ORDER BY set, step;


-- 3. image_size(): maps an image img to its width and height

SELECT DISTINCT substr(encode(i.img, 'base64'), 1500, 20) AS img, i.width, i.height
FROM   instructions AS i;



-- Check whether FDs hold in table instructions

-- 1. {set, step} ￫ page  "an instruction step is printed on one page" 
-- (function printed_on())

SELECT DISTINCT 'FD {set, step} ￫ page does not hold'
FROM   instructions AS i
GROUP BY i.set, i.step
HAVING COUNT(DISTINCT i.page) > 1;

SELECT 'FD {set, step} ￫ page does hold'
WHERE NOT EXISTS (SELECT 1
                  FROM   instructions AS i
                  GROUP BY i.set, i.step
                  HAVING COUNT(DISTINCT i.page) > 1);


-- 2. {set, page} ￫ step  "any page only displays a single instruction step" 

SELECT 'FD {set, page} ￫ step does hold'
WHERE NOT EXISTS (SELECT 1
                  FROM   instructions AS i
                  GROUP BY i.set, i.page
                  HAVING COUNT(DISTINCT i.step) > 1);


-- 3. {img} ￫ width  "any image has a defined width" 
-- (function image_size())

SELECT 'FD {img} ￫ width does hold'
WHERE NOT EXISTS (SELECT 1
                  FROM   instructions AS i
                  GROUP BY i.img
                  HAVING COUNT(DISTINCT i.width) > 1);


-- 4. {quantity, color} ￫ color   (trivial FD) 

SELECT 'FD {quantity, color} ￫ color does hold' AS "trivial"
WHERE NOT EXISTS (SELECT 1
                  FROM   instructions AS i
                  GROUP BY i.quantity, i.color
                  HAVING COUNT(DISTINCT i.color) > 1);


-- 5. Key FD: {set, step, piece, color} ￫ c  holds for any column c  

SELECT 'FD {set, step, piece, color} ￫ quantity does hold' AS "key"
WHERE NOT EXISTS (SELECT 1
                  FROM   instructions AS i
                  GROUP BY i.set, i.step, i.piece, i.color
                  HAVING COUNT(DISTINCT i.quantity) > 1);
