-- Add constraints to enforce the rules of the calendar mini-world

DROP TABLE IF EXISTS calendar;

CREATE TABLE calendar (
  no          integer,     -- appointment number
  appointment text,        -- type of appointment
  start       timestamp,   -- appointment start time (yyyy-mm-dd hh:mm:ss)
  stop        timestamp
);


-- Establish constraints, then populate the table state


-- 1. Appointment numbers must be defined and unique
ALTER TABLE calendar
  ALTER no SET NOT NULL;

ALTER TABLE calendar
  ADD UNIQUE(no);

-- 5. Appointments need a defined purpose (no “catch all” appointments).
ALTER TABLE calendar
  ALTER appointment SET NOT NULL;

-- 4. No appointments beyond 7pm
ALTER TABLE calendar
  ADD CONSTRAINT "no appointments beyond 7pm"
  CHECK (stop :: time <= '19:00');

ALTER TABLE calendar
  ADD CONSTRAINT "start before stop"
  CHECK (start <= stop);

-- 3. Breaks (lunches, …) should last at least one hour.
-- (recall: a ⇒ b ≡ ¬a ∨ b)
ALTER TABLE calendar
  ADD CONSTRAINT "breaks last longer than one hour"
  CHECK (appointment NOT IN ('lunch', 'breakfast')
         OR (stop - start) >= '01:00:00');


-- Sample data to exercise the constraints
INSERT INTO calendar VALUES
  (1, 'team meeting', 'today 09:30', 'today 10:30'),
  (2, 'lecture',      'today 10:15', 'today 11:45');

INSERT INTO calendar VALUES
  (2, 'lunch',        'today 12:00', 'today 13:00');

INSERT INTO calendar VALUES
  (3, NULL,           'today 12:00', 'today 12:30');

INSERT INTO calendar VALUES
  (3, 'lunch',        'today 12:00', 'today 12:30');

INSERT INTO calendar VALUES
  (3, 'presentation', 'today 18:00', 'today 20:00');


TABLE calendar;


------------------------------------------------------------------------
-- Implementations for the "appointments may not overlap" constraint
-- (this constraint spans alls rows of the calendar table and can thus
-- not be formulated in terms of row-local CHECK constraints)

-- 2. Appointments may not overlap
CREATE OR REPLACE FUNCTION calendar_overlap_check()
 RETURNS trigger AS
$$
 BEGIN
   IF EXISTS(SELECT 1
             FROM   calendar c
             WHERE  tsrange(NEW.start, NEW.stop) && tsrange(c.start, c.stop))
     THEN RAISE EXCEPTION '% overlaps with existing appointments', NEW;
     ELSE RETURN NEW;
   END IF;
 END;
$$ LANGUAGE PLPGSQL;

CREATE TRIGGER calendar_no_overlap
 BEFORE INSERT OR UPDATE ON calendar
 FOR EACH ROW
 EXECUTE PROCEDURE calendar_overlap_check();


INSERT INTO calendar VALUES (3, 'lunch', 'today 11:30', 'today 12:30');


-- -- 2. Alternative implementation based on CREATE RULE
-- CREATE RULE calendar_no_overlap AS
--   ON INSERT TO calendar
--   WHERE EXISTS(SELECT 1
--                FROM   calendar c
--                WHERE  tsrange(NEW.start, NEW.stop) && tsrange(c.start, c.stop))
--   DO INSTEAD NOTHING;

-- CREATE RULE calendar_no_overlap_update AS
--   ON UPDATE TO calendar
--   WHERE EXISTS(SELECT 1
--                FROM   calendar c
--                WHERE  tsrange(NEW.start, NEW.stop) && tsrange(c.start, c.stop))
--   DO INSTEAD NOTHING;
