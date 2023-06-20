-- 1. Run this SQL script from your shell via
--
--   $ psql -Xqf extract-instructions-image.sql
--
-- 2. Cut & paste the generated base64 output here to convert
--    the binary data back to a PNG:
--    https://base64.guru/converter/decode/image

\c lego
set schema 'lego';

\pset border 0
\pset tuples_only
\pset format unaligned
\timing off

SELECT DISTINCT encode(i.img, 'base64')
FROM   instructions AS i
WHERE  i.set = '9495-1' AND i.step = 10;
