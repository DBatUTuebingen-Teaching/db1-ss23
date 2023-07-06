-- Demonstrate use of system-generated IDENTITY columns (⚠️ new as of PostgreSQL 10)

\c scratch

DROP TABLE IF EXISTS t CASCADE;

-- IDENTITY columns must be of type smallint, integer, or bigint

CREATE TABLE t (
  __id__  integer GENERATED ALWAYS AS IDENTITY, -- NOT NULL is implicit, UNIQUE/PRIMARY KEY is not
  a       integer,
  b       text
);

ALTER TABLE t
  ADD PRIMARY KEY (__id__);

-- Omit __id__ from column list to have its values populated automatically
INSERT INTO t(a, b) VALUES
  (10, 'ten'),
  (20, 'twenty'),
  (30, 'thirty');

TABLE t;

-- We cannot interfere/overwrite ALWAYS generated identity value
-- (to enforce overwriting use INSERT INTO t(...) OVERRIDING SYSTEM VALUE ...)
INSERT INTO t(__id__, a, b) VALUES
  (4, 40, 'fourty');

TABLE t;


-----------------------------------------------------------------------

-- Identity columns are implemented in terms of SQL sequences
-- (see http://www.postgresql.org/docs/current/sql-createsequence.html)

-- The sequence associated with an IDENTITY column ‹c› in table ‹t›
-- is named '‹t›_‹c›_seq'.

SELECT currval('t___id___seq');

-- Further sequence functions:
--  - nextval(seq)
--  - setval(seq, integer)
--
-- (see http://www.postgresql.org/docs/current/functions-sequence.html)

-- Can use this knowledge and sequence function nextval() to cooperate with
-- auto-incrementation:

INSERT INTO t(__id__, a , b) OVERRIDING SYSTEM VALUE VALUES
  (nextval('t___id___seq'), 50, 'fifty');   -- nextval(...) evaluates to 4
                                            -- and increments sequence

TABLE t;

INSERT INTO t(a, b) VALUES
  (60, 'sixty'); -- OK, no error

TABLE t;

