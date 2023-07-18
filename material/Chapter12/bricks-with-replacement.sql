-- Demonstrate the use of outer join in SQL

-- Query:
-- "Find the bricks of LEGO Set 336–1 (Fire Engine) along with possible
-- replacement bricks"

\c lego

set schema 'lego';

SELECT b.piece, b.name, r.piece2
FROM   (bricks b
          JOIN                    -- also: INNER JOIN, NATURAL JOIN
        contains c
          USING (piece)
       )
         LEFT OUTER JOIN
       replaces r
         ON c.piece = r.piece1 AND c.set = r.set
WHERE  c.set = '336-1';
