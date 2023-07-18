# -*- coding: utf-8 -*

# Demonstrate the use relational division

# Query: "Find the sets that contain all bricks required to build
#         LEGO Set 1609 (Ship)."

from DB1 import *

# relevant tables

contains = Table('contains-small.csv')
sets = Table('sets-small.csv')

# these pieces are needed for LEGO Set 1609: Ship
# http://www.bricklink.com/SL/1609-1.jpg
needed = project(['piece'], select(lambda t:t['set'] == '1609-1', contains))

# RA query
#
#                           π[set,name,img]
#                           |
#                           ⋈
#                          /  \
#                      sets    ÷
#                            /   \
#                           /     \
#                  π[set,piece]   |
#                         |       |
#                     contains  needed
#
# runs in about 60 s

q = project(['set','name','img'],
      natjoin(
        sets,
        division(project(['set','piece'], contains), needed)))

# print output

for row in q:
  print(row)






# answer is
#
#  set 5590-1: Whirl and Wheel Super Truck
#  set 6285-1: Black Seas Barracuda
#  set 6985-1: Cosmic Fleet Voyager
#  set 740-1 : Basic Building Set
#  set 1609-1: the Ship itself

# NB: brick color and quantity not checked yet (→ students' task)
