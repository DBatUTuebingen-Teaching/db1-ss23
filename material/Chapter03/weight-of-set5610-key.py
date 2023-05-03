# coding=utf8

# Compute the overall weight of all pieces in
# LEGO set 5610-1 ("Builder")

from DB1 import Table

contains = Table('contains.csv')
bricks   = Table('bricks.csv')
minifigs = Table('minifigs.csv')


# Optimization #1: abort bricks/minifigs scan once piece has been found
#                  (piece is unique in bricks and minifigs), piece is
#                  either found in bricks or in minifigs
# ~2.2s

weight = 0

for c in contains:
  if c['set'] == '5610-1':
    for b in bricks:
      if c['piece'] == b['piece']:
        weight = weight + int(c['quantity']) * float(b['weight'])
        break                                           # ⚠ break
    else:                                               # ⚠ for...else
      for m in minifigs:
        if c['piece'] == m['piece']:
          weight = weight + int(c['quantity']) * float(m['weight'])
          break                                         # ⚠ break

print(weight)
