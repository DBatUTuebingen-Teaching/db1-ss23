# -*- coding: utf-8 -*

# Demonstrate the use of non-monotonic algebraic operators

# RA query:
# "Find those LEGO sets in which all bricks are yellow."

from DB1 import *

# relevant LEGO database tables (NB: small variants)

sets = Table('sets-small.csv')
contains = Table('contains-small.csv')
colors = Table('colors.csv')


# RA query (plan as discussed in lecture)

               π[set,name,img]
               |
               ⋈
              /  \
           sets   -
                /   \
           π[set]    π[set]
             |       |
           sets      σ[color ≠ 'Yellow']
                     |
                     π[set,color←name]
                     |
                     ⋈
                    / \
            contains   colors

q = project(['set','name','img'],
      natjoin(
        sets,
        difference(
          project(['set'], sets),
          project(['set'],
            select(lambda t:t['yellow'] != 'Yellow',
              project(lambda t:{'set':t['set'], 'yellow':t['color']},
                natjoin(contains, colors)))))))


# Optimized RA query
#
#               π[set,name,img]
#               |
#               ⋈
#              /  \
#           sets   -
#                /   \
#           π[set]    π[set]
#             |       |
#           sets      ⋈[color ≠ yellow]
#                    /  \ ┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈ 1 tuple only
#             contains   π[yellow←color]
#                        |
#                        σ[name = 'Yellow']
#                        |
#                      colors
#
# runs in about 2s

q = project(['set','name','img'],
      natjoin(
        sets,
        difference(
          project(['set'], sets),
          project(['set'],
            join(lambda t:t['color'] != t['yellow'],
              contains,
              project(lambda t:{'yellow':t['color']},
                select(lambda t:t['name'] == 'Yellow', colors)))))))


# print output

for row in q:
  print(row)
