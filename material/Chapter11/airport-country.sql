-- Map ER diagram (many-to-one relationship)
--
--    ❨hub❩               ❨long❩              ❨continent❩
--      |                   |                    |
--  [airport]––(1,1)––⟨located in⟩––(0,*)––[country]
--      |                   |                    |
--   ❨_iata_❩              ❨lat❩                ❨name❩
--
-- to SQL DDL statements.

\c scratch

DROP TABLE IF EXISTS airports;
DROP TABLE IF EXISTS countries;

-- Step #1 Entity Types

CREATE TABLE airports (
  iata char(3),   -- three-character IATA airport code (e.g., ZRH = Zürich)
  hub  text       -- if this is a hub: airline name
);

CREATE TABLE countries (
  name text,      -- city name ...
  continent text  -- ... lies on continent
);


-- Step #1b Entity Type Keys

-- rely on value-based identitifcation
ALTER TABLE airports
  ADD PRIMARY KEY (iata);

-- implement entity identity in terms of artifical key column
ALTER TABLE countries
  ADD COLUMN __id__ integer GENERATED ALWAYS AS IDENTITY;
ALTER TABLE countries
  ADD PRIMARY KEY (__id__);


-- Step #3 Many-to-One Relationship Type

-- establish foreign key to refer to country
ALTER TABLE airports
  ADD COLUMN located_in integer NOT NULL;
ALTER TABLE airports
  ADD FOREIGN KEY (located_in) REFERENCES countries (__id__);

-- add relationship attributes
ALTER TABLE airports
  ADD COLUMN lat real;
ALTER TABLE airports
  ADD COLUMN long real;

-- Show resulting relational schema

\d airports
\d countries

INSERT INTO countries(name, continent) VALUES
  ('Switzerland', 'Europe'),
  ('Germany',     'Europe'),
  ('Australia',   'Australia')
  -- RETURNING __id__, name -- get hold of articial keys that have been assigned
;

-- NB: reads country codes from countries table
INSERT INTO airports(iata, hub, located_in, lat, long) VALUES
  ('ZRH', 'Swiss',     (SELECT __id__ FROM countries WHERE name = 'Switzerland'),  47.464722,   8.549167),
  ('BER', NULL,        (SELECT __id__ FROM countries WHERE name = 'Germany'),      52.366667,  13.503333),
  ('FRA', 'Lufthansa', (SELECT __id__ FROM countries WHERE name = 'Germany'),      50.026421,   8.543125),
  ('SYD', 'Qantas',    (SELECT __id__ FROM countries WHERE name = 'Australia'),   -33.946111, 151.177222);


TABLE countries;
TABLE airports;



-----------------------------------------------------------------------
-- Use WITH and RETURNING to synchronize the two inserts on country key

TRUNCATE airports CASCADE;
TRUNCATE countries CASCADE;

WITH cs(__id__, name) as (
  INSERT INTO countries(name, continent) VALUES
    ('Switzerland', 'Europe'),
    ('Germany',     'Europe'),
    ('Australia',   'Australia')
    RETURNING __id__, name
)
INSERT INTO airports(iata, hub, located_in, lat, long) VALUES
  ('ZRH', 'Swiss',     (SELECT __id__ FROM cs WHERE name = 'Switzerland'),  47.464722,   8.549167),
  ('BER', NULL,        (SELECT __id__ FROM cs WHERE name = 'Germany'),      52.366667,  13.503333),
  ('FRA', 'Lufthansa', (SELECT __id__ FROM cs WHERE name = 'Germany'),      50.026421,   8.543125),
  ('SYD', 'Qantas',    (SELECT __id__ FROM cs WHERE name = 'Australia'),   -33.946111, 151.177222);

TABLE countries;
TABLE airports;
