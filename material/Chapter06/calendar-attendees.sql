-- Create calender and attendees tables to demonstrate
-- SQL's SELECT-FROM queries (order of subqueries in FROM clause is
-- immaterial)

DROP TABLE IF EXISTS calendar;
DROP TABLE IF EXISTS attendees;

CREATE TABLE calendar (
  appointment text,        -- type of appointment
  start       time,        -- appointment start time (hh:mm:ss)
  stop        time
);

INSERT INTO calendar(appointment, start, stop) VALUES
  ('meeting', '11:30', '12:00'),
  ('lunch',   '12:00', '13:00'),
  ('biking',  '18:30', NULL);

-- Lists 3 rows

CREATE TABLE attendees (
  appointment text,        -- type of appointment
  person      text         -- (first) name of attendee
);

INSERT INTO attendees(appointment, person) VALUES
  ('meeting', 'Alex'),
  ('meeting', 'Bert'),
  ('meeting', 'Cora'),
  ('lunch',   'Bert'),
  ('lunch',   'Drew');

-- Lists 5 rows
TABLE attendees;


-- The order of subqueries in the FROM clause is immaterial
-- (`,' under FROM is commutative)

-- Queries (1) and (2) list 3 × 5 rows (all possible row combinations)

-- (1)
SELECT c.appointment AS appointment, c.start AS start, c.stop AS stop,
       a.appointment AS "appointment*", a.person AS person
FROM   (TABLE calendar) AS c,
       (TABLE attendees) AS a;

-- (2)
SELECT c.appointment AS appointment, c.start AS start, c.stop AS stop,
       a.appointment AS "appointment*", a.person AS person
FROM   (TABLE attendees) AS a,
       (TABLE calendar) AS c;


-- Demonstrate that (1) and (2) yield identical result tables

-- S, T (multi)sets.  S = T <=> S - T = ∅ = T - S

-- Yields 0 rows
SELECT c.appointment AS appointment, c.start AS start, c.stop AS stop,
       a.appointment AS "appointment*", a.person AS person
FROM   (TABLE calendar) AS c,
       (TABLE attendees) AS a
  EXCEPT
SELECT c.appointment AS appointment, c.start AS start, c.stop AS stop,
       a.appointment AS "appointment*", a.person AS person
FROM   (TABLE attendees) AS a,
       (TABLE calendar) AS c;

-- Yields 0 rows
SELECT c.appointment AS appointment, c.start AS start, c.stop AS stop,
       a.appointment AS "appointment*", a.person AS person
FROM   (TABLE attendees) AS a,
       (TABLE calendar) AS c
  EXCEPT
SELECT c.appointment AS appointment, c.start "AS start", c.stop AS stop,
       a.appointment AS "appointment*", a.person AS person
FROM   (TABLE calendar) AS c,
       (TABLE attendees) AS a;


-- EXPLAIN shows that Pg reorders the subqueries to yield
-- the same internal representation anyway:
EXPLAIN
SELECT c.appointment AS appointment, c.start AS start, c.stop AS stop,
       a.appointment AS "appointment*", a.person AS person
FROM   (TABLE calendar) AS c,
       (TABLE attendees) AS a;

EXPLAIN
SELECT c.appointment AS appointment, c.start AS start, c.stop AS stop,
       a.appointment AS "appointment*", a.person AS person
FROM   (TABLE attendees) AS a,
       (TABLE calendar) AS c;
