# Demonstrate the use of relational algebra: selection

from DB1 import *

# sample table
data = [ {'A':1, 'B':True,  'C':20 },
         {'A':1, 'B':True,  'C':10 },
         {'A':2, 'B':False, 'C':10 } ]

r = Table(data)

# RA selection queries

q = select(lambda t: int(t['A']) == 1, r)
# q = select(lambda t: bool(t['B']), r)
# q = select(lambda t: int(t['C']) > 20, r)
# q = select(lambda t: int(t['D']) == 0, r)

# print output
for row in q:
	print(row)
