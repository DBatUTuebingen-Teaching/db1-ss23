# Compute the overall weight of all pieces in
# LEGO set 5610-1 ("Builder")

from DB1 import Table
from collections import Counter
import concurrent.futures

contains = Table('contains.csv')
bricks   = Table('bricks.csv')
minifigs = Table('minifigs.csv')

# Optimization #3: scan bricks and minifigs in separate threads,
#                  then weight afterwards
# ~1.3s [O(|contains| + max(|bricks|, |minifigs|))
#        lion share of time is spent in contains scan, little parallel work]

quantity = Counter()

for c in contains:
  if c['set'] == '5610-1':
    quantity[c['piece']] += int(c['quantity'])

# print(quantity)

def scan_bricks():
  weight = 0
  for b in bricks:
    if b['piece'] in quantity:
      weight += quantity[b['piece']] * float(b['weight'])
  return weight

def scan_minifigs():
  weight = 0
  for m in minifigs:
    if m['piece'] in quantity:
      weight += quantity[m['piece']] * float(m['weight'])
  return weight

with concurrent.futures.ThreadPoolExecutor() as executor:
    weights = [executor.submit(scan_bricks)  .result(),
               executor.submit(scan_minifigs).result()]

print(weights[0] + weights[1])
