from DB1 import Table

earthquakes = Table('earthquakes.csv')

for quake in earthquakes:
   print({ 'place': quake['place'],
           'mag':   float(quake['mag']) })
