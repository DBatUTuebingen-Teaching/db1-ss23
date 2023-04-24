# Compute the overall weight of all pieces in
# LEGO set 5610-1 ("Builder")

from DB1 import Table

contains = Table('contains.csv')
bricks   = Table('bricks.csv')
minifigs = Table('minifigs.csv')

weight = 0.0

for c in contains:
  if c['set'] == '5610-1':
    for b in bricks:
      if b['piece'] == c['piece']:
        weight = weight + int(c['quantity']) * float(b['weight'])
    for m in minifigs:
      if m['piece'] == c['piece']:
        weight = weight + int(c['quantity']) * float(m['weight'])

print(weight)


# List-oriented variant

weight = sum([ sum([ int(c['quantity']) * float(b['weight'])
                     for b in bricks if b['piece'] == c['piece'] ])
                +
               sum([ int(c['quantity']) * float(m['weight'])
                     for m in minifigs if m['piece'] == c['piece'] ])
               for c in contains if c['set'] == '5610-1' ])

print(weight)

