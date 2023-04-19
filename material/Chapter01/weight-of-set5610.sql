-- (1) Create a (single-column) table to hold textual LEGO set data

DROP TABLE IF EXISTS lego_sets;
CREATE TABLE lego_sets (
  id  integer,
  set text
);

-- (2) Load text data (will result in a single row loaded into table lego_sets)

INSERT INTO lego_sets(id, set) VALUES
(5610, '
LEGO™ Set "Builder" (set no 5610-1)
Category: Town (City, Construction)

Contains 20 pieces: 19 bricks, 1 minifigure

5610-1 Builder is a City impulse set released in 2008. It contains a construction worker
with a rolling cement mixer, along with 3 dark grey studs that resemble mortar or concrete.
When the mixer is pushed, the drum turns. The drum can also tilt side-to-side, but not
enough to dump the studs.

Brick#  Color/Weight  Name

1x 6157     Black/1.12g    Plate, Modified 2 x 2 with Wheels Holder Wide
2x 3139     Black/0.4g    Tire 14mm D. x 4mm Smooth Small Single
1x 3839b    Black/0.61g    Plate, Modified 1 x 2 with Handles - Flat Ends, Low Attachment
1x 30663    Black/0.4g    Vehicle, Steering Wheel Small, 2 Studs Diameter
1x 6222     Dark Bluish Gray/3.57g    Brick, Round 4 x 4 with Holes
2x 32530    Dark Bluish Gray/0.64g    Technic, Pin Connector Plate 1 x 2 x 1 2/3 with 2 Holes (Double on Top)
1x 4742     Dark Bluish Gray/3.77g    Cone 4 x 4 x 2 Hollow No Studs
1x 6587     Dark Bluish Gray/0.48g    Technic, Axle 3 with Stud
3x 4073     Dark Bluish Gray/0.12g    Plate, Round 1 x 1 Straight Side
2x 4624     Light Bluish Gray/0.22g    Wheel 8mm D. x 6mm
1x 3679     Light Bluish Gray/0.3g    Turntable 2 x 2 Plate, Top
1x 32064b   Yellow/0.75g    Technic, Brick 1 x 2 with Axle Hole - New Style with X Opening
1x 3795     Yellow/1.74g    Plate 2 x 6
1x 3680     Yellow/0.47g    Turntable 2 x 2 Plate, Base
1x 4073     Dark Bluish Gray/0.12g     Plate, Round 1 x 1 Straight Side
1x 4624     Light Bluish Gray/0.22g    Wheel 8mm D. x 6mm
2x 4624c01  Light Bluish Gray/0.61g    Wheel  8mm D. x 6mm, with Black Tire 14mm D. x 4mm Smooth Small Single (4624 / 3139)
1x 32064    Yellow/0.88g    Technic, Brick 1 x 2 with Axle Hole
1x 3680c02  Yellow/0.66g    Turntable 2 x 2 Plate, Complete Assembly with Light Bluish Gray Top

Minifig#  Weight  Name

1x cty052    3.27g    Construction Worker - Orange Zipper, Safety Stripes, Orange Arms, Orange Legs, Red Construction Helmet
');


-- (3) SQL query:
-- What is the overall weight of the LEGO sets?

SELECT   ls.id, SUM(m[1] :: int * m[2] :: float) AS weight
FROM     lego_sets AS ls,
LATERAL  regexp_matches(ls.set, '^([0-9]+)x.+[ /]([0-9.]+)g.*$', 'gm') AS m
GROUP BY ls.id;
