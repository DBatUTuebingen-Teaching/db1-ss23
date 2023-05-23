-- Demonstrates the concepts of row types and row values

DROP TABLE IF EXISTS calendar CASCADE;
DROP TYPE IF EXISTS calendar CASCADE;

-- Creates table `calendar' as well as row type `calendar'
CREATE TABLE calendar (
  appointment text,        -- type of appointment
  start       time,        -- appointment start time (hh:mm:ss)
  stop        time
);



-- Check that row type `calendar' has been registered with Pg's catalog
-- (has been added to 𝕋):
SELECT t1.typname AS row_type,
       a.attnum AS column_pos, a.attname AS column_name, t2.typname AS column_type
FROM   pg_type AS t1, pg_attribute AS a, pg_type AS t2
WHERE  t1.typname = 'calendar'
AND    t1.typrelid = a.attrelid
AND    a.attnum > 0                  -- omit Pg-defined virtual system columns
AND    a.atttypid = t2.oid;


INSERT INTO calendar(appointment, start, stop) VALUES
  ('meeting', '11:30', '12:00'),
  ('lunch',   '12:00', '13:00'),
  ('biking',  '18:30', NULL);


-- Observe the difference:

-- result table of 3 rows, 3 columns
SELECT c.*
FROM   calendar AS c;

-- result table of 3 rows, 1 column of row type `calendar'
SELECT c AS "row values"
FROM   calendar AS c;



-- Create a composite row value of the above row type (keyword `ROW` optional)
SELECT ROW('lecture', '14:15', '15:45') :: calendar;

-- Access a column of a row value
SELECT (ROW('lecture', '14:15', '15:45') :: calendar).appointment;

-- Fails: no column names in a non-table row value
-- ERROR:  could not identify column "appointment" in record data type
SELECT (ROW('lecture', '14:15', '15:45')).appointment;



-- Alternatively:
-- 1. Create row type first
-- 2. Create table based on row type

DROP TABLE IF EXISTS calendar CASCADE;
DROP TABLE IF EXISTS schedule;


CREATE TYPE calendar AS (
  appointment text,        -- type of appointment
  start       time,        -- appointment start time (hh:mm:ss)
  stop        time
);

CREATE TABLE schedule OF calendar;

\d schedule
