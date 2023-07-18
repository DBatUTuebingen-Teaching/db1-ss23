from DB1 import *

m = [ {'c':4}, {'c':8} ]
n = [ {'d':3}, {'d':1},  {'d':7} ]

x = [ {'c': 4, 'd': 3},
      {'c': 4, 'd': 1},
      {'c': 4, 'd': 7},
      {'c': 8, 'd': 3},
      {'c': 8, 'd': 1},
      {'c': 8, 'd': 7} ]

for row in division(x, m):
  print(row)
