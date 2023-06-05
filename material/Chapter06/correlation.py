# Simulate the use of scalar SQL subqueries in PyQL
# (uses function single() to convert a single-row list
#  into a scalar value)

from DB1 import Table

users = Table([ { 'name': 'Alex', 'rating': 5 },
                { 'name': 'Bert', 'rating': 1 },
                { 'name': 'Cora', 'rating': 4 } ])

# Simulate the SQL semantics:
#
# +-----+
# | ... |
# +-----+  =  <v>
# | <v> |
# +-----+
def single(xs):
  try:
    h, t = xs[0], xs[1:]
    if t:
      raise Exception('more than one element in a list used as an expression')
    return h
  except IndexError:
    return None


for u in users:
  print( { 'name':  u['name'],
           'stars': single([ s['stars']
                             for s in Table([ { 'rating': 1, 'stars': '*'    },
                                              { 'rating': 2, 'stars': '**'   },
                                              { 'rating': 3, 'stars': '***'  },
                                              { 'rating': 4, 'stars': '****' },
                                              { 'rating': 5, 'stars': '*****'} ])
                             if s['rating'] == u['rating'] ])
         } )
