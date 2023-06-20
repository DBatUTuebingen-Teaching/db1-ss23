-- Demonstrate the use of GROUP BY to condense the "who is busy at what times?"
-- report


DROP TABLE IF EXISTS calendar CASCADE;
DROP TABLE IF EXISTS attendees CASCADE;

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

-- Who is busy at what times?
-- Uncondensed: multiple rows per attendee

SELECT c.*, a.*
FROM   calendar AS c, attendees AS a
WHERE  c.appointment = a.appointment;

SELECT a.person, c.start, c.stop
FROM   calendar AS c, attendees AS a
WHERE  c.appointment = a.appointment;


-- Condensed:

-- Collapse multiple appointments for a person,
-- report start of first/end of last meeting
-- (columns person|start|stop)

SELECT a.person, min(c.start) AS start, max(c.stop) AS stop
FROM   calendar AS c, attendees AS a
WHERE  c.appointment = a.appointment
GROUP BY  a.person;


SELECT a.person,
       min(c.start) AS start, max(c.stop) AS stop
FROM   calendar AS c, attendees AS a
WHERE  c.appointment = a.appointment
GROUP BY a.person;


-- Collapse multiple appointments for a person,
-- also report number of appointments and average duration
SELECT a.person,
       count(*)              AS appointments,
       avg(c.stop - c.start) AS "average duration",
       min(c.start)          AS start,
       max(c.stop)           AS stop
FROM   calendar AS c, attendees AS a
WHERE  c.appointment = a.appointment
GROUP BY a.person;

---------------------------------------------------------------------

-- Find the overworked employees (whose longest meetings last ⩾ 1 hours)

SELECT a.person
FROM   calendar AS c, attendees AS a
WHERE  c.appointment = a.appointment
GROUP BY a.person
HAVING max(c.stop) - min(c.start) >= '01:00:00';
