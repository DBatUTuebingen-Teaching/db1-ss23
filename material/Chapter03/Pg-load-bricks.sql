DROP TABLE IF EXISTS bricks;

CREATE TABLE bricks (
  piece   text,
  type    char(1),
  name    text,
  cat     integer,
  weight  real,
  img     text,
  x       real,
  y       real,
  z       real
);

\COPY bricks(piece, type, name, cat, weight, img, x, y, z) FROM 'bricks-no-header.csv';
