# Compute the overall weight of all pieces in
# LEGO set 5610-1 ("Builder")

from DB1 import Table

contains = Table('contains.csv')
bricks   = Table('bricks.csv')
minifigs = Table('minifigs.csv')


# Optimization #2: build a temporary "table" of relevant 5610-1 pieces
#                  and their quantities
# O(|contains| + |bricks| + |minifigs|)
#
# ~1.2s

weight = 0.0

# Phase 1
quantity = {}

for c in contains:
  if c['set'] == '5610-1':
    if c['piece'] in quantity:
      quantity[c['piece']] += int(c['quantity'])
    else:
      quantity[c['piece']] = int(c['quantity'])

# print(quantity)





# Phase 2 (refers to quantity only, not contains)
for b in bricks:
  if b['piece'] in quantity:
    weight = weight + quantity[b['piece']] * float(b['weight'])

for m in minifigs:
  if m['piece'] in quantity:
    weight = weight + quantity[m['piece']] * float(m['weight'])

print(weight)
