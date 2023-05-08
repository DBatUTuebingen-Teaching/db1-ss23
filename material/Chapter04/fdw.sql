-- Populate a table from a CSV file using PostgreSQL's file_fdw foreign data wrapper

-- Note: Replace the two '/Users/grust/...' paths below to point to
--       a location in your file system.

-- 1. Create a suitable sample CSV file (e.g., using COPY ... TO ...)

DROP FOREIGN TABLE IF EXISTS calendar;
DROP TABLE IF EXISTS calendar;

CREATE TABLE calendar (
  appointment text,        -- type of appointment
  start       time,        -- appointment start time (hh:mm:ss)
  stop        time);

INSERT INTO calendar(appointment, start, stop) VALUES
  ('meeting', '11:30', '12:00'),
  ('lunch',   '12:00', '13:00'),
  ('biking',  '18:30', NULL);

TABLE calendar;

\COPY calendar TO '/Users/grust/DB1/repo/Notes/Week03/live/calendar.csv';

DROP TABLE calendar;

-- 2. Install and prepare file_fdw foreign data wrapper

CREATE EXTENSION IF NOT EXISTS file_fdw;

DROP SERVER IF EXISTS files CASCADE;
CREATE SERVER files FOREIGN DATA WRAPPER file_fdw;

-- 3. Create foreign table based on CSV file (LIKE not allowed here :-()

CREATE FOREIGN TABLE calendar (
  appointment text,        -- type of appointment
  start       time,        -- appointment start time (hh:mm:ss)
  stop        time)
  SERVER files
  OPTIONS (filename '/Users/grust/DB1/repo/Notes/Week03/live/calendar.csv');

-- 4. Query foreign table

TABLE calendar;

-- 5. Synchronization (file --> table, but not table --> file):

-- You can now edit the CSV file `calendar.csv' to see changes
-- reflected in the foreign table (check via TABLE calendar).

-- The file-based foreign data table is read-only.  This will fail:
DELETE FROM calendar c
  WHERE c.appointment = 'lunch';

-- 6. Clean-up
-- DROP FOREIGN TABLE calendar;
