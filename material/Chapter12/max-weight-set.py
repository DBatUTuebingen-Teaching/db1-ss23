# -*- coding: utf-8 -*

# Demonstrate the use of non-monotonic algebraic operators

# RA query:
# "Find the heaviest LEGO set."

from DB1 import *

# relevant LEGO database table (NB: small variant)

sets = Table('sets-small.csv')


# (1) formulate RA query with set difference
#
#               -
#             /   \
#          sets    π[sch(sets)]               ⎫
#                  |                          ⎬  ⋉ (lsemijoin)
#                  ⋈[weight < weight2]        ⎭
#                 /  \
#              sets   π[weight2←weight]
#                     |
#                    sets
#
# runs in about 20s

q = difference(
     sets,
     project(schema(sets),
       join(lambda t:float(t['weight'] or 0) < float(t['weight2'] or 0),
         sets,
         project(lambda t:{'weight2':t['weight']}, sets))))

# Reformulated using left semijoin ⋉ (lsemijoin)

# q = difference(
#      sets,
#      lsemijoin(lambda t:float(t['weight'] or 0) < float(t['weight2'] or 0),
#        sets,
#        project(lambda t:{'weight2':t['weight']}, sets)))



# (2) formulate RA query with left antijoin
#
#                  ▷[weight < weight2]
#                 /  \
#              sets   π[weight2←weight]
#                     |
#                    sets

# q = lantijoin(lambda t:float(t['weight'] or 0) < float(t['weight2'] or 0),
#       sets,
#       project(lambda t:{'weight2':t['weight']}, sets))

# print output

for row in q:
  print(row)
