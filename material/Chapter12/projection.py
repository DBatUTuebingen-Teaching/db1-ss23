# Demonstrate the use of relational algebra: projection

from DB1 import *

# sample table
data = [ {'A':1, 'B':True,  'C':20 },
         {'A':1, 'B':True,  'C':10 },
         {'A':2, 'B':False, 'C':10 } ]

r = Table(data)

# RA projection queries

q = project(lambda t: { 'X':int(t['A']) + int(t['C']), 'Y':not(bool(t['B'])), 'Z':"LEGO" }, r)
# q = project(lambda t: { 'X':t['A'], 'Y':t['B']}, r)
# q = project(['A'], r)

# print output

for row in q:
  print(row)
