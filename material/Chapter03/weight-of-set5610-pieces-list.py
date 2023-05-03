# Compute the overall weight of all pieces in
# LEGO set 5610-1 ("Builder")

from DB1 import Table

contains = Table('contains.csv')
bricks   = Table('bricks.csv')
minifigs = Table('minifigs.csv')

# A piece is either a brick or a minifig: build the union (make sure to
# only retain the features common for both piece types)
pieces = [ m for m in minifigs ]     \
         +                           \
         [ { 'piece':  b['piece'],
             'type':   b['type'],
             'name':   b['name'],
             'cat':    b['cat'],
             'weight': b['weight'],
             'img':    b['img']    } for b in bricks ]


weight = 0

for c in contains:
  if c['set'] == '5610-1':
    for p in pieces:
      if c['piece'] == p['piece']:
        weight = weight + int(c['quantity']) * float(p['weight'])
        break

print(weight)
