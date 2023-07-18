# -*- coding: utf-8 -*

# Demonstrate the use of outer join.

# Query:
# "Find the bricks of LEGO Set 336–1 (Fire Engine) along with possible
#  replacement bricks"

from DB1 import *

# relevant LEGO database tables (NB: small variants)

contains = Table('contains.csv')
bricks = Table('bricks.csv')
replaces = Table('replaces.csv')

# initial RA query (⚠️ faulty: produces only a single row)
#
#
#                    π[piece,name,piece2]
#                    |
#                    ⋈
#                  /   \
#                 /     π[piece←piece1,piece2,set]
#                ⋈      |
#              /    \  replaces
#             /      \
#            |        π[set,piece]
#            |        |
#     π[piece,name]   σ[set = '336-1']
#            |        |
#         bricks   contains
#
# runs in about 30s

q = project(['piece','name','piece2'],
      natjoin(
        natjoin(
          project(['piece','name'], bricks),
          project(['set','piece'],
            select(lambda t:t['set'] == '336-1', contains))),
        project(lambda t:{'piece':t['piece1'], 'piece2':t['piece2'], 'set':t['set']}, replaces)))

# unexpected output (one row only):
# {'piece': '3004p50', 'name': 'Brick 1 x 2 with Lego Logo Old Style White with Black Outline Pattern', 'piece2': '3004pb053'}




# correct RA query (uses left outer join with replaces to also retain those
# pieces without a replacement):
#
#
#                   π[piece,name,piece2]
#                   |
#                   ⟕[piece = piece1 ⋀ set = set2]
#                  /   \
#                 /     π[piece1,piece2,set2←set]
#                ⋈      |
#              /    \  replaces
#             /      \
#            |        π[set,piece]
#            |        |
#     π[piece,name]   σ[set = '336-1']
#            |        |
#         bricks   contains
#
# runs in about 25s

q = project(['piece','name','piece2'],
      louterjoin(lambda t:t['piece'] == t['piece1'] and t['set'] == t['set2'],
        natjoin(
          project(['piece','name'], bricks),
          project(['set','piece'],
            select(lambda t:t['set'] == '336-1', contains))),
        project(lambda t:{'piece1':t['piece1'], 'piece2':t['piece2'], 'set2':t['set']}, replaces)))

# print output

for row in q:
  print(row)
