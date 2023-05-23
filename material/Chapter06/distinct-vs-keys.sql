-- In the queries below, the use of DISTINCT would be superfluous
-- (the database system could infer from the queries that the queries
-- will never yield duplicates)

DROP TABLE IF EXISTS ratings;

CREATE TABLE ratings (
  series  text,   -- name of TV series
  season  int,
  episode int,
  rating  float   -- rating on IMBD.com
);

ALTER TABLE ratings
  ADD PRIMARY KEY (series, season, episode);

ALTER TABLE ratings
  ADD CONSTRAINT rating1to10 CHECK (1 <= rating AND rating <=10);

INSERT INTO ratings(series, season, episode, rating) VALUES
  ('Breaking Bad',     4, 13, 9.8),
  ('Breaking Bad',     2,  9, 8.9),
  ('Breaking Bad',     5, 14, 9.9),
  ('Breaking Bad',     4, 10, 9.5),
  ('Game of Thrones',  5,  8, 9.9),
  ('Game of Thrones',  4, 10, 9.5),
  ('Game of Thrones',  4,  1, 9.1),
  ('Big Bang Theory',  5, 24, 8.6),
  ('Big Bang Theory', 11,  5, 7.4),
  ('Big Bang Theory', 11,  6, 7.3),
  ('Big Bang Theory',  4, 10, 7.9);


TABLE ratings;



-- Explicit duplicate removal has its costs:

EXPLAIN ANALYZE
SELECT DISTINCT r.*
FROM   ratings AS r;


EXPLAIN ANALYZE
SELECT r.*
FROM   ratings AS r;


-- 2. If the columns of a SELECT clause form a (super-)key for the
--    query result, no duplicate rows can be returned.

-- No duplicates
SELECT r.series, r.season, r.episode, r.rating > 8.0 AS "good?"
FROM   ratings AS r;

-- Duplicates: {r.season, r.episode, r.rating} is not a (super-)key for the query result
-- (duplicate: 4, 10, 9.5)
SELECT r.season, r.episode, r.rating
FROM   ratings AS r;


-- 3. If the WHERE clause contains conjunctive equality conditions
--    aᵢ = constᵢ (constᵢ literal) and the columns aᵢ together form a
--    (super-)key of the query result, at most one row will be returned.

SELECT r.*
FROM   ratings AS r
WHERE  r.series = 'Breaking Bad' AND r.season = 4 AND r.episode = 10;
-- alternative syntax:
-- WHERE ROW(r.series, r.season, r.episode) = ROW('Breaking Bad', 4, 10);


-- 4. If the SELECTed columns and the (constant) filtered columns in the
--    WHERE clause form a (super-)key of the result, no duplicate rows can
--    be returned.

-- No duplicates: {r.series, r.season, r.episode, r.rating} is a (super-)key
SELECT DISTINCT r.season, r.episode, r.rating
FROM   ratings AS r
WHERE  r.series = 'Breaking Bad';
