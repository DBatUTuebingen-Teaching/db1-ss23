-- Demonstrate the use of CASE...WHEN and UNION [ALL] to implement case distinction

\c lego

set schema 'lego';

-- "Categorize LEGO sets according to their stud volume into small, medium, and
--  large sets."

-- (1) CASE...WHEN

WITH sets_vol(set, name, vol) AS (
   SELECT s.set,
          left(s.name, 10),
          s.x * s.y * s.z AS vol
   FROM   sets s
)
SELECT s.set,
       s.name,
       s.vol,
       CASE WHEN s.vol < 1000 THEN                 'small'
            WHEN s.vol BETWEEN 1000 AND 10000 THEN 'medium'
            WHEN s.vol > 10000 THEN                'large'
            ELSE NULL -- default behavior: could be removed
       END AS size
FROM   sets_vol AS s
ORDER BY vol;







-- (2) UNION [ ALL ]

WITH sets_vol(set, name, vol) AS (
   SELECT s.set,
          left(s.name, 10),
          s.x * s.y * s.z AS vol
   FROM   sets s
)
SELECT set, name, vol, 'small' AS size
FROM   sets_vol s
WHERE  s.vol < 1000
--
  UNION ALL
--
SELECT set, name, vol, 'medium' AS size
FROM   sets_vol s
WHERE  s.vol BETWEEN 1000 AND 10000
--
  UNION ALL
--
SELECT set, name, vol, 'large' AS size
FROM   sets_vol s
WHERE  s.vol > 10000
--
ORDER BY vol;
