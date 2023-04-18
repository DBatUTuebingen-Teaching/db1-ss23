(: Magnitude of worst earthquake in the northern hemisphere :)

let $earthquakes := json-doc("earthquakes.json")
return
  (: all earthquakes in the northern hemisphere :)
  let $northern_earthquakes :=
    for $quake in members($earthquakes.features)
      let $latitude := $quake.geometry.coordinates[[2]]
    where $latitude gt 0.0
    return $quake
  (: maximum magnitude of earthquakes on northern hemisphere :)
  let $mag := max(for $quake in $northern_earthquakes
                  return $quake.properties.mag)
  return
    $mag



