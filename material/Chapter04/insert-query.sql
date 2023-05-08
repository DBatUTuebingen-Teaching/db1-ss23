-- Copy schema and state of an existing table

-- Create and populate source table
DROP TABLE IF EXISTS calendar;

CREATE TABLE calendar (
  appointment text,        -- type of appointment
  start       time,        -- appointment start time (hh:mm:ss)
  stop        time);

INSERT INTO calendar(appointment, start, stop) VALUES
  ('meeting', '11:30', '12:00'),
  ('lunch',   '12:00', '13:00'),
  ('biking',  '18:30', NULL);

-- Lists 3 rows
TABLE calendar;

-- Create table `agenda', a copy of existing table `calendar'
DROP TABLE IF EXISTS agenda;

-- 1. Copy schema
CREATE TABLE agenda (LIKE calendar);

-- schema like table calendar, but empty state
TABLE agenda;

-- LIKE <t>: copies column names and data types from existing table <t>

-- 2. Copy state
INSERT INTO agenda(appointment,start,stop)
  TABLE calendar;

-- List copied table
TABLE agenda;


-- Alternatively:
--
-- One combined SQL DDL+DML command that integrates steps 1. (copy schema)
-- and 2. (copy state): CREATE TABLE ‹t› AS ‹query›.  In this example:
--
--   CREATE TABLE agenda AS TABLE calendar
