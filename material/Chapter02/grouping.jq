let $xs := [ 1, 2, 3, 4, 5, 6 ]
return
  for $x in members($xs)
  group by $even := $x mod 2 = 0
  return { "even": $even, "group": count($x) }
