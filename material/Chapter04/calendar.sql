DROP TABLE IF EXISTS calendar;

CREATE TABLE calendar (
  appointment text,        -- type of appointment
  start       time,        -- appointment start time (hh:mm:ss)
  stop        time);


-- Lists 0 rows (empty state)
TABLE calendar;


INSERT INTO calendar(appointment, start, stop) VALUES
  ('meeting', '11:30', '12:00'),
  ('lunch',   '12:00', '13:00'),
  ('biking',  '18:30', NULL   );


-- Lists 3 rows
TABLE calendar;


-- Deletes 2 rows
DELETE FROM calendar AS c
 WHERE c.start <= '12:00';

TABLE calendar;

-- Insert rows (includes a duplicate)
INSERT INTO calendar(appointment, start) VALUES
  ('biking', '15:00'),
  ('biking', '18:30');

TABLE calendar;

-- Shift all evening events by one hour (modifies 2 rows)
UPDATE calendar AS c
   SET start = c.start + '01:00:00'
 WHERE c.start >= '18:00:00';

TABLE calendar;

-- Cannot tell the duplicates apart, both will be deleted
DELETE FROM calendar AS c
 WHERE c.appointment = 'biking' AND c.start = '19:30';

TABLE calendar;
