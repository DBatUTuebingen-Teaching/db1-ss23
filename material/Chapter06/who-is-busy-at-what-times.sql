-- Demonstrates equi-join queries

DROP TYPE IF EXISTS calendar CASCADE;

DROP TABLE IF EXISTS calendar CASCADE;
DROP TABLE IF EXISTS attendees;

CREATE TABLE calendar (
  appointment text,             -- type of appointment
  start       timestamp,        -- appointment start time (yyyy-mm-dd hh:mm:ss)
  stop        timestamp
);

ALTER TABLE calendar
  ALTER appointment SET NOT NULL;

ALTER TABLE calendar
  ADD CHECK (start < stop);

ALTER TABLE calendar
  ADD UNIQUE(appointment, start, stop);


INSERT INTO calendar(appointment, start, stop) VALUES
  ('meeting', 'today 11:30', 'today 12:00'),
  ('lunch',   'today 12:00', 'today 13:00'),
  ('biking',  'today 18:30', NULL);


CREATE TABLE attendees (
  appointment text,        -- type of appointment
  person      text         -- (first) name of attendee
);

ALTER TABLE attendees
  ADD PRIMARY KEY(appointment, person);


INSERT INTO attendees(appointment, person) VALUES
  ('meeting', 'Alex'),
  ('meeting', 'Bert'),
  ('meeting', 'Cora'),
  ('lunch',   'Bert'),
  ('lunch',   'Drew');

TABLE calendar;

TABLE attendees;

-- "Arbitrary" join between calendar and attendees
-- Join result size: |calendar| × |attendees| rows
-- (cross join, Cartesian product)

SELECT c.*, a.*
FROM   calendar AS c, attendees AS a
WHERE  true;                        -- optional: typically omitted

-- Who is busy at what times?

SELECT c.*, a.*
FROM   calendar AS c, attendees AS a
WHERE  c.appointment = a.appointment;


-- Improve presentation of output (sorting)

SELECT a.person, c.start, c.stop
FROM   calendar AS c, attendees AS a
WHERE  c.appointment = a.appointment
ORDER BY a.person, c.start;



/*
-- Advanced: coalesce adjacent busy intervals

-- For convenience, define a view that contains the busy schedule with
-- non-coalesced busy intervals
DROP VIEW IF EXISTS busy;
CREATE VIEW busy(person, start, stop) AS
  SELECT a.person, c.start, c.stop
  FROM   calendar c, attendees a
  WHERE  c.appointment = a.appointment;


-- Variant : use SQL window functions
-- (see http://wiki.postgresql.org/wiki/Range_aggregation)
--
SELECT b2.person, MIN(b2.start) AS start, MAX(b2.stop) AS end
FROM   (SELECT b1.*, FIRST_VALUE(b1.earliest_start) OVER (PARTITION BY b1.person ORDER BY b1.start, b1.stop) AS interval
        FROM (SELECT b.*,
                     CASE WHEN b.start <= MAX(b.stop) OVER w THEN NULL ELSE b.start END AS earliest_start
              FROM   busy AS b
              WINDOW w AS (PARTITION BY b.person ORDER BY b.start, b.stop ROWS UNBOUNDED PRECEDING EXCLUDE CURRENT ROW)) AS b1) AS b2
GROUP BY b2.interval, b2.person;


-- Variant : use recursive common table epxression
--
-- Each recursive step coalesces immediately adjacent busy intervals
WITH RECURSIVE schedule(person, start, stop) AS (
    TABLE busy
  UNION ALL
    SELECT DISTINCT b.person, LEAST(s.start, b.start) AS start, GREATEST(s.stop, b.stop) AS stop
    FROM   schedule s, busy b
    WHERE  b.person = s.person
    -- the following condition could be relaxed to also search for
    -- overlapping but non-equal intervals (operators &&, <>)
    AND    tsrange(s.start, s.stop) -|- tsrange(b.start, b.stop)
)
-- Only select those busy intervals that are not contained in any other
-- busy interval of the same person
SELECT s1.*
FROM   schedule s1
WHERE  NOT EXISTS (SELECT 1
                   FROM   schedule s2
                   WHERE  s1.person = s2.person
                   AND    tsrange(s2.start, s2.stop) <> tsrange(s1.start, s1.stop)
                   AND    tsrange(s2.start, s2.stop) @> tsrange(s1.start, s1.stop));
*/

DROP TABLE IF EXISTS rooms;

CREATE TABLE rooms (
  room  text,
  open  timestamp,
  close timestamp
);

ALTER TABLE rooms
  ALTER room SET NOT NULL;

ALTER TABLE rooms
  ADD UNIQUE(room, open, close);


INSERT INTO rooms VALUES
  ('cafeteria',    'today 12:00', 'today 13:30'),
  ('lobby',        'today 08:00', 'today 12:00'),
  ('lobby',        'today 14:00', 'today 18:00'),
  ('lecture hall', 'today 08:00', 'today 18:00');


TABLE rooms;

-- θ-join: Which rooms are available for the scheduled appointments?

SELECT c.*, r.room
FROM   calendar AS c, rooms AS r
WHERE  r.open <= c.start AND c.stop <= r.close;



-- 3-way join: Where will I probably find people during the day?

-- "Arbitrary" combination of rows from all three tables:
-- Join result size: |calendar| × |attendees| × |rooms| rows
SELECT c.appointment, r.room, a.person
FROM   calendar AS c, rooms AS r, attendees AS a;


-- Note: omitting any of the join conditions will lead to result that is too large
SELECT a.person, r.room, c.start, c.stop
FROM   calendar AS c, rooms AS r, attendees AS a
WHERE  r.open <= c.start AND c.stop <= r.close
       AND c.appointment = a.appointment;


-- Result representation:
SELECT a.person, r.room, c.start, c.stop
FROM   calendar AS c, rooms AS r, attendees AS a
WHERE  r.open <= c.start AND c.stop <= r.close
       AND c.appointment = a.appointment
ORDER BY a.person, c.start;
