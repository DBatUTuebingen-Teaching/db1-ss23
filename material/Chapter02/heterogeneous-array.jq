let $xs := [1, 2, "three", 4, 5]    (: ⚠️ :)
return
    for $x in members($xs)
    return $x + 1
