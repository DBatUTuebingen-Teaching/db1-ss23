# -*- coding: utf-8 -*

# RA query:
# "Categorize LEGO sets according to their stud volume into small, medium, and
#  large sets."

from DB1 import *

# relevant LEGO database tables

sets = Table('sets.csv')

# RA query:
#
#                                   |
#             ┌──────────────────── ∪ ───────────────────┐
#             |                                          |
#  ┌───────── ∪ ──────────┐                              |
#  |                      |                              |
#  π[set,name,vol,        π[set,name,vol,                π[set,name,vol,
#  | size←'small']        | size←'medium']               | size←'large']
#  |                      |                              |
#  σ[vol < 1000]          σ[vol >= 1000 ∧ vol < 10000]   σ[vol >= 10000]
#  └──────────────────────┼──────────────────────────────┘
#                         π[set,name,vol←x*y*z]
#                         |
#                        sets
#
# runs in < 4 seconds

q1 = project(lambda t:{'set' :t['set'],
                       'name':t['name'][:10],
                       'vol' :float(t['x'] or 0) * float(t['y'] or 0) * float(t['z'] or 0) }, sets)

small =  project(lambda t:{'set' :t['set'],'name':t['name'],'vol':t['vol'],'size':'small'},
           select(lambda t:t['vol'] < 1000, q1))
medium = project(lambda t:{'set' :t['set'],'name':t['name'],'vol':t['vol'],'size':'medium'},
           select(lambda t:t['vol'] >= 1000 and t['vol'] <= 10000, q1))
large =  project(lambda t:{'set' :t['set'],'name':t['name'],'vol':t['vol'],'size':'large'},
           select(lambda t:t['vol'] > 10000, q1))


# these ∪ are guaranteed to not encounter duplicates
# but we cannot indicate that (on the RA level)

q = union(union(small, medium), large)

# print output (filtered, sorted)

for row in sorted(select(lambda t:t['vol'] > 0, q), key=lambda t:t['vol']):
  print(row)
