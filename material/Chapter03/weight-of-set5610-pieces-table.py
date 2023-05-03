# Compute the overall weight of all pieces in
# LEGO set 5610-1 ("Builder")

from DB1 import Table

# NB: this depends on the presence of table `pieces.csv', i.e., the "union"
# of `bricks.csv' and `minifigs.csv'.  May be constructed in the UNIX shell
# via
#     cut -f1-6 bricks.csv | last +2 | cat minifigs.csv - > pieces.csv

contains = Table('contains.csv')
pieces   = Table('pieces.csv')





weight = 0

for c in contains:
  if c['set'] == '5610-1':
    for p in pieces:
      if c['piece'] == p['piece']:
        weight = weight + int(c['quantity']) * float(p['weight'])
        break

print(weight)
