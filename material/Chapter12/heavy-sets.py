# -*- coding: utf-8 -*

# RA query:
# "Find LEGO sets (set ID, name) heavier than the large Taj Mahal set."

from DB1 import *

# relevant LEGO database tables

sets = Table('sets.csv')

# Optimized RA query (after selection splitting/pushdown):
#
#            π[set,name,weight]
#            |
#            ⋈[weight2 < weight]
#           /  \
#       sets    π[weight2←weight]
#               |
#               σ[name = 'Taj Mahal']
#               |
#              sets
#
# runs in < 1 second

q = project(['set','name','weight'],
      join(lambda t:float(t['weight2'] or 0) < float(t['weight'] or 0),
        sets,
        project(lambda t:{'weight2':t['weight']},
          select(lambda t:t['name'] == 'Taj Mahal',
            sets))))

# print output

for row in q:
  print(row)
