# Find magnitude *and place* of the strongest earthquake
# in the northern hemipshere

# Uses imperative style: variables place and mag updated
# in the iteration

from DB1 import Table

earthquakes = Table('earthquakes.csv')


mag = 0.0
place = ''

for quake in earthquakes:
  if float(quake['latitude']) >= 0.0:
    if float(quake['mag']) > mag:
      mag   = float(quake['mag'])         # ⚠️ variable update
      place = quake['place']              # ⚠️ variable update

print({'mag':mag, 'place':place})

