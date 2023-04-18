let $xs := [ 1, 2, 3 ]
let $ys := { "one": "eins", "two": "zwei", "three": "drei" }
return
  for $y in keys($ys)
  return $ys.$y
