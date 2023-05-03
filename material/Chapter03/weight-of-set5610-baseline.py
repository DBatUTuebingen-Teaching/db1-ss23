# Compute the overall weight of all pieces in
# LEGO set 5610-1 ("Builder")

from DB1 import Table

contains = Table('contains.csv')
bricks   = Table('bricks.csv')
minifigs = Table('minifigs.csv')


# No optimization (nested loops)
# ~4.5s, O(|contains| + pieces(5610) × (|bricks| + |minifigs|))

weight = 0

for c in contains:
  if c['set'] == '5610-1':
    for b in bricks:
      if c['piece'] == b['piece']:
        weight = weight + int(c['quantity']) * float(b['weight'])
    for m in minifigs:
      if c['piece'] == m['piece']:
        weight = weight + int(c['quantity']) * float(m['weight'])

print(weight)
