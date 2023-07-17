# -*- coding: utf-8 -*

# Demonstrate the use of non-monotonic algebraic operators

# RA query:
# "Find those LEGO sets that do not contain any stickers."

from DB1 import *

# relevant LEGO database tables (NB: small variants)

sets = Table('sets-small.csv')
contains = Table('contains-small.csv')
bricks = Table('bricks-small.csv')


# runs in about 30s

# formulation based on set difference

# (1) Identify the LEGO bricks with stickers
q1 = select(lambda t:t['name'].find('Sticker') >= 0,
       bricks)

# (2) Find the sets that contain these LEGO bricks
q2 = project(['set'],
       natjoin(
         contains,
         q1))

# (3) These are exactly those sets that do *not* interest us
q3 = difference(project(['set'], sets), q2)

# (4) Attach set name and other set information of interest
q4 = project(['set','name'], natjoin(sets, q3))


# Algebraic plan:
#
#                 π[set,name]
#                 |
#                 ⋈
#                /  \
#             sets   -
#                  /   \
#             π[set]    π[set]
#               |       |
#             sets      ⋈
#                      /  \
#               contains   σ[name ~ 'Sticker']
#                          |
#                        bricks


# q = project(['set','name'],
#       natjoin(
#         sets,
#         difference(
#           project(['set'], sets),
#           project(['set'],
#             natjoin(
#               contains,
#                 select(lambda t:find(t['name'], 'Sticker') >= 0,
#                   bricks))))))

# print output

for row in q4:
  print(row)
