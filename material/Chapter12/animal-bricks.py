# -*- coding: utf-8 -*

# RA query:
# "Find piece ID and name of all LEGO bricks that belong to a category
#  related to animals."

from DB1 import *

# relevant LEGO database tables

bricks = Table('bricks.csv')
categories = Table('categories.csv')

# RA query
#
# Initial vanilla π-σ-⋈ plan:
#
#              π[piece,name]
#              |
#              σ[name2 ~ 'Animal']
#              |
#              ⋈[cat = cat2]
#             /  \
#        bricks   π[cat2←cat, name2←name]
#                 |
#             categories
#
#
# ⚠️ runs for 10s and uses heaps of memory (Cart product of bricks and categories)

q = project(['piece','name'],
      select(lambda t:t['name2'].find('Animal') >= 0,
        join(lambda t:int(t['cat']) == int(t['cat2']),
          bricks,
          project(lambda t:{'cat2':t['cat'], 'name2':t['name']}, categories))))


# Equivalent plan after
#  - selection pushdown
#  - projection pushdown
#  - (rewriting θ-join into natural join):
#
#               π[piece,name]
#               |
#               ⋈
#              /  \
#         bricks   π[cat]
#                  |
#                  σ[name ~ 'Animal']
#                  |
#              categories
#
# runs in ~ 1s

q = project(['piece','name'],
      natjoin(
        bricks,
        project(['cat'],
          select(lambda t:t['name'].find('Animal') >= 0, categories))))

# print output

for row in q:
  print(row)
