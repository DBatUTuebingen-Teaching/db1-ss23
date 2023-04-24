
import sys
if sys.version < "3":
  sys.exit("You need Python3 to use this version of " + __file__)

import csv
import io

csv.register_dialect('table', skipinitialspace=True, delimiter='\t')

class Table:
  """
  Provide a suitable table abstraction.  Initialize via
  - Table(<file.csv>) to read from CSV file (column headers in first row)
  - Table('...') to read CSV contents directly from string literal
  - Table([...]) to "read" a list of Python dictionaries (= rows)
  """
  def __init__(self, input):
    if isinstance(input, list):
      # case: Table([...])
      self.input = input
      self.rows = iter(self.input)
      try:
        self.fields = list(self.input[0].keys())
      except IndexError:
        self.fields = None
      return

    try:
      # case: Table(<file.csv>)
      self.input = open(input, 'r', encoding='utf8')
    except FileNotFoundError:
      # case: Table('...')
      self.input = io.StringIO(input)

    self.rows = csv.DictReader(self.input, dialect='table')
    self.fields = self.rows.fieldnames

  def __iter__(self):
    # automatically rewind input file if iteration begins
    # (facilitates the formulation of nested queries)
    self.rewind()
    return self

  def __next__(self):
    row = self.rows.__next__()
    # Translate `\N' in CSV into None (PostgreSQL convention for NULL)
    return { col:val if val != '\\N' else None for col, val in row.items() }

  # reset iterator such that CSV file is read from row #1 on next iteration
  def rewind(self):
    if isinstance(self.input, list):
      self.rows = iter(self.input)
    else:
      self.input.seek(0)
      self.rows.__init__(self.input, dialect='table')

  # generate CSV file from table contents
  def dump(self, f):
    self.rewind()

    with open(f, 'w', newline='') as output:
      writer = csv.DictWriter(output, fieldnames=self.fields, dialect='table')
      writer.writeheader()
      for row in self.rows:
        writer.writerow({ col:val if val is not None else '\\N' for col, val in row.items() })


class Grouping(dict):
  """
  Represent a grouping of item in terms of a
  { key:..., group:... } dicitionary of arrays
  """
  def __init__(self, *arg, **kw):
    super(Grouping, self).__init__(*arg, **kw)
    self.groups = {}

  def __setitem__(self, key, val):
      self.groups[key] = val

  def __getitem__(self, key):
      try:
        self.groups[key]
      except KeyError:
        self.groups[key] = []

      return self.groups[key]

  def __iter__(self):
      for k,g in self.groups.items():
        yield { 'key':k, 'group':g }

  def __len__(self):
      return len(self.groups)

  def __repr__(self):
      return repr(self.groups)

  def get(self, key, default):
      return self.groups.get(key, default)

  def items(self):
      return self.groups.items()

  def iteritems(self):
      return self.groups.iteritems()

  def iterkeys(self):
      return self.groups.iterkeys()

  def itervalues(self):
      return self.groups.itervalues()

  def keys(self):
      return self.groups.keys()

  def values(self):
      return self.groups.values()

# -----------------------------------------------------------------------

# An implementation of Relational Algebra.
#
# Basic operators:
#   - project
#   - select
#   - cross
#   - union
#   - difference
#
# Derived operators:
#   - join
#   - lsemijoin
#   - rsemijoin
#   - lantijoin
#   - rantijoin
#   - intersect
#   - rename
#   - division
#   - louterjoin
#   - routerjoin
#   - outerjoin

# auxiliary routines

def dupe(r):
  """Return the list of unique elements in xs."""
  s = []
  for row in list(r):
    if row not in s:
      s += [row]
  return s

def schema(r):
  """Return *the* schema for relation r."""
  sch = dupe([ row.keys() for row in list(r) ])
  # the empty relation has an empty schema
  if not sch:
    return set()
  assert(len(sch) == 1)
  return set(sch[0])

def matches(s1, s2):
  """Return true iff schemata s1, s2 match."""
  # the empty schema matches with any other schema
  return (not s1 or not s2) or s1 == s2

# the five basic operation of the relational algebra

def project(l, r):
  """Apply function l (or column list) to relation r and return resulting relation."""
  schema(r)
  if type(l) in [list, set]:
    cs = l
    l = lambda t: { c:t[c] for c in cs }
  return dupe([ l(row) for row in list(r) ])

def select(p, r):
  """Return those rows of relation r that satisfy predicate p."""
  schema(r)
  return [ row for row in list(r) if p(row) ]

def cross(r1, r2):
  """Return the Cartesian product of relations r1, r2."""
  assert(not(schema(r1) & schema(r2)))
  return [ dict(list(row1.items()) + list(row2.items())) for row1 in list(r1) for row2 in list(r2) ]

def union(r1, r2):
  """Return the union of relations r1, r2."""
  assert(matches(schema(r1), schema(r2)))
  return dupe([ row1 for row1 in list(r1) ] + [ row2 for row2 in list(r2) ])

def difference(r1, r2):
  """Return the difference of r1, r2 (a subset of r1)."""
  assert(matches(schema(r1), schema(r2)))
  return [ row1 for row1 in list(r1) if row1 not in list(r2) ]

# derived operations (relational algebra "macros")

def join(p, r1, r2):
  """Return the theta-join of relations r1, r2 according to predicate p."""
  # the original RA macro:
  # return select(p, cross(r1, r2))
  # for efficiency reasons we inline select() and cross() here:
  assert(not(schema(r1) & schema(r2)))
  return [ row for row1 in list(r1) for row2 in list(r2) for row in [dict(list(row1.items()) + list(row2.items()))] if p(row) ]

def natjoin(r1, r2):
  """Return the natural join of relations r1, r2."""
  def prime(c):
    return c + "'"
  cs = schema(r1) & schema(r2)
  p = lambda t: all([ t[c] == t[prime(c)] for c in cs ])
  l = lambda t: dict([ (prime(c),t[c]) for c in cs ] + [ (c,t[c]) for c in schema(r2) - cs ])
  return project(schema(r1) | schema(r2), join(p, r1, project(l, r2)))

def lsemijoin(p, r1, r2):
  """Return the left semijoin of relations r1, r2 according to predicate p."""
  return project(schema(r1), join(p, r1, r2))

def rsemijoin(p, r1, r2):
  """Return the right semijoin of relations r1, r2 according to predicate p."""
  return project(schema(r2), join(p, r1, r2))

def lantijoin(p, r1, r2):
  """Return the left anit-semijoin of relations r1, r2 according to predicate p."""
  return difference(r1, lsemijoin(p, r1, r2))

def rantijoin(p, r1, r2):
  """Return the left anit-semijoin of relations r1, r2 according to predicate p."""
  return difference(r2, rsemijoin(p, r1, r2))

def intersect(r1, r2):
  """Return the intersection of relations r1, r2."""
  return difference(r1, difference(r1, r2))

def rename(s, r):
  """Return r after all its attribute names have been suffixed with s."""
  cs = schema(r)
  return project(lambda t:{ c + s:t[c] for c in cs }, r)

def division(r1, r2):
  """Return the relational division of r1 by r2."""
  cs = schema(r1) - schema(r2)
  return difference(
           project(cs, r1),
           project(cs, difference(cross(project(cs, r1), r2), r1)))

def louterjoin(p, r1, r2):
  """Return the left outer join of relations r1, r2."""
  return union(
           join(p, r1, r2),
           cross(
             lantijoin(p, r1, r2), [ { c:None for c in schema(r2) } ]))

def routerjoin(p, r1, r2):
  """Return the right outer join of relations r1, r2."""
  return union(
           join(p, r1, r2),
           cross(
             rantijoin(p, r1, r2), [ { c:None for c in schema(r1) } ]))

def outerjoin(p, r1, r2):
  """Return the full outer join of relations r1, r2."""
  return union(
           join(p, r1, r2),
           union(
             cross(
               lantijoin(p, r1, r2), [ { c:None for c in schema(r2) } ]),
             cross(
               rantijoin(p, r1, r2), [ { c:None for c in schema(r1) } ])))


# -----------------------------------------------------------------------

if __name__ == '__main__':

  # from DB1 import Table, Grouping

  # A sample CSV "file"
  file = r'''a	b	c

 1	\N	10
 1	3	20
10	20	30'''

  # Table access (CSV file)
  t = Table(file)

  # Iterate over table rows
  for row in t:
    print(row)

  # Project on named columns
  t = Table(file)
  for row in t:
    print(row['a'], row['c'])

  # Arithmetic with columns
  t = Table(file)
  for row in t:
    print(41 + int(row['a']))

  # Selection
  t = Table(file)
  for row in t:
    if int(row['a']) == 1:
      print(row)

  # Cartesian product
  t1 = Table(file)
  t2 = Table(file)
  for row1 in t1:
    for row2 in t2:
      print(row1, row2)

  # Join
  t1 = Table(file)
  t2 = Table(file)
  for row1 in t1:
    for row2 in t2:
      if int(row1['a']) == int(row2['c']):
        print(row1['b'])

  # Grouping and aggregation
  t1 = Table(file)
  g = Grouping()

  for row in t1:
    g[int(row['a'])].append(row)

  for row in g:
    print(row['key'], sum([ int(e['c']) for e in row['group'] ]))

  print(g)

  # COUNT(...) --> len(...)
  # x IN q     --> x in q
  # EXISTS(q)  --> len(q) != 0, bool(q)
  # DISTINCT   --> set(...)
  # NULL       --> None

  # Table access (list of dictionaries)
  data = [ {'a':  1, 'b': None, 'c': 10},
           {'a':  1, 'b':    3, 'c': 20},
           {'a': 10, 'b':   20, 'c': 30} ]

  t1 = Table(data)
  t2 = Table(data)

  for row1 in t1:
    for row2 in t2:
      if int(row1['a']) == int(row2['c']):
        print(row1['b'])




  for row in project(lambda r:{'x':r['a'], 'y':r['c']},
              join(lambda r:int(r['a']) == int(r['c']),
                project(['a'], t1),
                project(['c'], t2))):
    print(row)

  for row in natjoin(project(['a','b'], t1),
                     project(['b','c'], t1)):
    print(row)

  for row in rename('2', t1):
    print(row)
