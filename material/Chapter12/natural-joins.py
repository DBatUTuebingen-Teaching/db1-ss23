# -*- coding: utf-8 -*

# Demonstrate natural joins

from DB1 import *

# sample tables
data1 = [ {'A':1, 'B':True,  'C':20 },
          {'A':1, 'B':True,  'C':10 },
          {'A':2, 'B':False, 'C':10 } ]

data2 = [ { 'B':True,  'C':20, 'D':'X' },
          { 'B':False, 'C':10, 'D':'Y' },
          { 'B':True,  'C':30, 'D':'Z' } ]

r1 = Table(data1)
r2 = Table(data2)

# natural join queries

q1 = natjoin(r1, r2)

# {'A': 1, 'C': 20, 'B': True, 'D': 'X'}
# {'A': 2, 'C': 10, 'B': False, 'D': 'Y'}


# q1 = natjoin(project(['B','C'], r1), project(['B','C'], r2))

# sch(R1) = sch(R2) => R1 ⨝ R2 = R1 ∩ R2
# {'C': 20, 'B': True}
# {'C': 10, 'B': False}


# q1 = natjoin(r1, r1)

# R ⨝ R = R
# {'A': 1, 'C': 20, 'B': True}
# {'A': 1, 'C': 10, 'B': True}
# {'A': 2, 'C': 10, 'B': False}


# q1 = natjoin(project(['A','C'], r1), project(['B','D'], r2))

# sch(R1) ∩ sch(R2) = ∅ => R1 ⨝ R2 = R1 × R2
# {'A': 1, 'C': 20, 'B': True, 'D': 'X'}
# {'A': 1, 'C': 20, 'B': False, 'D': 'Y'}
# {'A': 1, 'C': 20, 'B': True, 'D': 'Z'}
# {'A': 1, 'C': 10, 'B': True, 'D': 'X'}
# {'A': 1, 'C': 10, 'B': False, 'D': 'Y'}
# {'A': 1, 'C': 10, 'B': True, 'D': 'Z'}
# {'A': 2, 'C': 10, 'B': True, 'D': 'X'}
# {'A': 2, 'C': 10, 'B': False, 'D': 'Y'}
# {'A': 2, 'C': 10, 'B': True, 'D': 'Z'}


# print output

for row in q1:
	print(row)

