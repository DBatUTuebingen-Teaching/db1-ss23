# Demonstrate the use of relational algebra: Cartesian product (selection, projection)

from DB1 import *

# sample graph (adjacency table)
#
#  A 🡘 B
#  🡓    🡓
#  D    C

data = [ {'from':'A', 'to':'B' },
         {'from':'B', 'to':'A' },
         {'from':'B', 'to':'C' },
         {'from':'A', 'to':'D' } ]

# equivalent input (⚠️ TAB-separated columns)
#
# data = r'''from	to
# A	B
# B	A
# B	C
# A	D'''


g = Table(data)

# RA query: paths of length two

# combine all edges with each other
q1 = cross(g, project(lambda t:{ 'from2':t['from'], 'to2':t['to']}, g))

# end point of first edge must meet start point of second edge
q2 = select(lambda t:t['to'] == t['from2'], q1)

# project middle point away
q3 = project(lambda t:{ 'from':t['from'], 'to':t['to2']}, q2)

# print output
for row in q3:
  print(row)
