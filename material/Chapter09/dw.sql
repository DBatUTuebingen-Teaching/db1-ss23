set schema 'lego';

-- Build a tiny LEGO Data Warehouse (star schema)

DROP TABLE IF EXISTS sales;
DROP TABLE IF EXISTS stores;
DROP TABLE IF EXISTS dates;

-- Dimension tables: sets, stores, dates

-- NB: The sets dimension is borrowed from the LEGO database

CREATE TABLE stores (
  store   serial,      -- unique store ID
  city    text,        -- store location
  state   text,
  country text
);

ALTER TABLE stores
  ADD PRIMARY KEY (store);


CREATE TABLE dates (
  "date"  serial,       -- unique date ID
  "day"   integer,
  dow     integer,      -- day of week (Sun = 1)
  "month" integer,
  quarter integer,
  "year"  integer
);

ALTER TABLE dates
  ADD PRIMARY KEY ("date");


-- Fact table: sales

CREATE TABLE sales (
  sale   serial,        -- unique sale ID
  "set"  id,            -- references to the dimension tables
  "date" integer,
  store  integer,
  items  integer,       -- number of items sold
  price  money          -- at what price
);

ALTER TABLE sales
  ADD PRIMARY KEY (sale);

-- Establish the star structure:

ALTER TABLE sales
  ADD FOREIGN KEY (set) REFERENCES sets;
ALTER TABLE sales
  ADD FOREIGN KEY ("date") REFERENCES dates;
ALTER TABLE sales
  ADD FOREIGN KEY (store) REFERENCES stores;


-- Load/generate table contents

-- LEGO stores (derived from shop.lego.com)
INSERT INTO stores(country, state, city) VALUES
  ('Germany', 'Berlin',   'BERLIN'),
  ('Germany', 'NRW',      'ESSEN'),
  ('Germany', 'NRW',      'OBERHAUSEN'),
  ('Germany', 'NRW',      'KÖLN'),
  ('Germany', 'Hessen',   'FRANKFURT'),
  ('Germany', 'Hessen',   'WIESBADEN'),
  ('Germany', 'Hamburg',  'HAMBURG'),
  ('Germany', 'Sachsen',  'LEIPZIG'),
  ('Germany', 'Bayern',   'MÜNCHEN'),
  ('Germany', 'Bayern',   'MÜNCHEN PASING'),
  ('Germany', 'Bayern',   'NÜRNBERG'),
  ('Germany', 'Saarland', 'SAARBRÜCKEN'),
  ('USA'    , 'AL',       'RIVERCHASE GALLERIA MALL'),
  ('USA'    , 'AZ',       'ARROWHEAD TOWNE CTR'),
  ('USA'    , 'AZ',       'CHANDLER FASHION CENTER'),
  ('USA'    , 'CA',       'ARDEN FAIR MALL'),
  ('USA'    , 'CA',       'DISNEYLAND RESORT'),
  ('USA'    , 'CA',       'FASHION VALLEY'),
  ('USA'    , 'CA',       'GLENDALE GALLERIA'),
  ('USA'    , 'CA',       'HILLSDALE SHOPPING CENTER'),
  ('USA'    , 'CA',       'ONTARIO MILLS'),
  ('USA'    , 'CA',       'SOUTH COAST PLAZA'),
  ('USA'    , 'CA',       'STONERIDGE MALL'),
  ('USA'    , 'CA',       'THE SHOPS AT MISSION VIEJO'),
  ('USA'    , 'CA',       'VALLEY FAIR'),
  ('USA'    , 'CO',       'COLORADO MILLS'),
  ('USA'    , 'CO',       'PARK MEADOWS MALL'),
  ('USA'    , 'DE',       'CHRISTINA MALL'),
  ('USA'    , 'FL',       'AVENTURA MALL'),
  ('USA'    , 'FL',       'DOWNTOWN DISNEY MARKETPLACE'),
  ('USA'    , 'FL',       'SAWGRASS MILLS'),
  ('USA'    , 'GA',       'DISCOVER MILLS'),
  ('USA'    , 'GA',       'NORTH POINT MALL'),
  ('USA'    , 'HI',       'ALA MOANA CENTER'),
  ('USA'    , 'IL',       'GURNEE MILLS'),
  ('USA'    , 'IN',       'CASTLETON SQUARE'),
  ('USA'    , 'KS',       'OAK PARK MALL'),
  ('USA'    , 'MA',       'BURLINGTON MALL'),
  ('USA'    , 'MA',       'NATICK COLLECTION'),
  ('USA'    , 'MA',       'NORTHSHORE MALL'),
  ('USA'    , 'MA',       'SOUTH SHORE PLAZA'),
  ('USA'    , 'MD',       'ARUNDEL MILLS'),
  ('USA'    , 'MD',       'WESTFIELD ANNAPOLIS SHOPPING CTR'),
  ('USA'    , 'MI',       'THE SOMERSET COLLECTION'),
  ('USA'    , 'MN',       'MALL OF AMERICA'),
  ('USA'    , 'MO',       'WEST COUNTY CENTER'),
  ('USA'    , 'NC',       'CONCORD MILLS'),
  ('USA'    , 'NC',       'CRABTREE MALL'),
  ('USA'    , 'NJ',       'BRIDGEWATER COMMONS'),
  ('USA'    , 'NJ',       'FREEHOLD RACEWAY MALL'),
  ('USA'    , 'NJ',       'JERSEY GARDENS'),
  ('USA'    , 'NJ',       'WESTFIELD GARDEN STATE PLAZA'),
  ('USA'    , 'NY',       'EASTVIEW MALL'),
  ('USA'    , 'NY',       'PALISADES CENTER'),
  ('USA'    , 'NY',       'QUEENS CENTER'),
  ('USA'    , 'NY',       'ROCKEFELLER CENTER'),
  ('USA'    , 'NY',       'ROOSEVELT FIELD'),
  ('USA'    , 'OH',       'BEACHWOOD PLACE'),
  ('USA'    , 'OH',       'EASTON TOWN CENTER'),
  ('USA'    , 'OH',       'KENWOOD TOWNE CENTRE'),
  ('USA'    , 'OK',       'PENN SQUARE MALL'),
  ('USA'    , 'OR',       'WASHINGTON SQUARE'),
  ('USA'    , 'PA',       'KING OF PRUSSIA MALL'),
  ('USA'    , 'TN',       'OPRY MILLS'),
  ('USA'    , 'TX',       'BARTON CREEK SQUARE'),
  ('USA'    , 'TX',       'BAYBROOK MALL'),
  ('USA'    , 'TX',       'HOUSTON GALLERIA'),
  ('USA'    , 'TX',       'NORTH PARK CENTRAL'),
  ('USA'    , 'TX',       'NORTH STAR MALL'),
  ('USA'    , 'TX',       'STONEBRIAR CENTRE'),
  ('USA'    , 'TX',       'THE WOODLANDS MALL'),
  ('USA'    , 'VA',       'POTOMAC MILLS MALL'),
  ('USA'    , 'VA',       'TYSONS CORNER'),
  ('USA'    , 'WA',       'ALDERWOOD'),
  ('USA'    , 'WA',       'BELLEVUE SQUARE MALL'),
  ('USA'    , 'WI',       'MAYFAIR'),
  ('USA'    , 'WI',       'NORTHBROOK COURT'),
  ('USA'    , 'WI',       'ORLAND SQUARE'),
  ('USA'    , 'WI',       'WATER TOWER PLACE'),
  ('USA'    , 'WI',       'WOODFIELD MALL');

-- Generate all dates from Jan 1, 2012 through Dec 31, 2013
INSERT INTO dates("day", dow, "month", quarter, "year")
  SELECT extract(day from d)        AS "day",
         to_char(d, 'D')::integer   AS dow,
         extract(month from d)      AS "month",
         to_char(d, 'Q')::integer   AS quarter,
         extract(year from d)       AS "year"
  FROM   generate_series('2012-01-01 00:00'::timestamp,
                         '2013-12-31 23:59'::timestamp,
                         '1 day') AS d;

-- Randomly generate sales, picking keys from the three dimension tables
INSERT INTO sales("set", "date", store, items, price)
  SELECT (SELECT array_agg(s.set::text)
          FROM   sets s)[1 + floor(random() * (SELECT count(*) FROM sets))]::id AS "set",
         (SELECT array_agg(d."date")
          FROM dates d)[1 + floor(random()  * (SELECT count(*) FROM dates))]    AS "date",
         (SELECT array_agg(s.store)
          FROM stores s)[1 + floor(random() * (SELECT count(*) FROM stores))]   AS store,
         1 + random() * 4                                                       AS items,
         5.0::money + (random() * 95)::numeric::money                           AS price
  FROM   generate_series(1,1000) AS s;


-- (Excerpts of the) Dimension tables
TABLE stores
LIMIT  10;

TABLE dates
LIMIT  10;

TABLE sets
LIMIT 10;

-- (Excerpt of the) Fact table
TABLE sales
LIMIT 10;

---------------------------------------------------------------------


-- Sales and turnover by country
SELECT s.country, count(*) AS sales, sum(f.items * f.price) AS turnover
FROM   sales AS f, stores AS s
WHERE  f.store = s.store
GROUP BY s.country;


-- Sales by date (granularity: 1 year)
SELECT d."year", count(*) AS sales
FROM   sales AS f, dates AS d
WHERE  f."date" = d."date"
GROUP BY d."year";


-- Sales by date (granularity: 3 months)
SELECT d."year", d.quarter, count(*) AS sales
FROM   sales AS f, dates AS d
WHERE  f."date" = d."date"
GROUP BY d."year", d.quarter;



-- Turnover by country and year
SELECT s.country, d."year", sum(f.items * f.price) AS turnover
FROM   sales AS f, stores AS s, dates AS d
WHERE  f.store = s.store
AND    f."date" = d."date"
GROUP BY s.country, d."year"
ORDER BY country, "year";


-- Number of items sold per category and country

SELECT s.country, p.cat, c.name, SUM(f.items) AS "# of items sold"
FROM   sales AS f, sets AS p, stores AS s, categories AS c
WHERE  f."set" = p."set"
AND    f.store = s.store
AND    p.cat = c.cat
GROUP BY s.country, p.cat, c.name
ORDER BY country, cat;



-- Group by multiple dimensions in a single table
-- (this simulates GROUP BY grouping sets ((year), (quarter), ()));
SELECT d."year", NULL AS quarter, count(*) AS sales
FROM   sales AS f, dates AS d
WHERE  f."date" = d."date"
GROUP BY d."year"

  UNION ALL

SELECT NULL AS "year", d.quarter, count(*) AS sales
FROM   sales AS f, dates AS d
WHERE  f."date" = d."date"
GROUP BY d.quarter

  UNION ALL

SELECT NULL "year", NULL AS quarter, count(*) AS sales
FROM   sales AS f, dates AS d
WHERE  f."date" = d."date"
-- no GROUP BY

ORDER BY "year", quarter;



-- Equivalent query using SQL's `GROUP BY grouping sets'
SELECT d."year", d.quarter, count(*) AS sales
FROM   sales AS f, dates AS d
WHERE  f."date" = d."date"
GROUP BY grouping sets ((quarter), ("year"), ())
ORDER BY "year", quarter;

---------------------------------------------------------------------


-- Clean up (leave a clean LEGO database)
DROP TABLE sales;
DROP TABLE stores;
DROP TABLE dates;

