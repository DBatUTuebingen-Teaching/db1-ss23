(: Magnitude AND PLACE of worst earthquake in the northern hemisphere :)

(: NB: Contains three variants of the same query. Uncomment as required. :)


(: Variant 1: iterate through quakes a second time :)

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
    for $quake in $northern_earthquakes
    where $quake.properties.mag eq $mag
    return
        { place: $quake.properties.place, mag: $mag }


(: Variant 2: based on universal quantifier empty() :)

(:
let $earthquakes := json-doc("earthquakes.json")
return
    (: all earthquakes in the northern hemisphere :)
    let $northern_earthquakes :=
        for $quake in members($earthquakes.features)
          let $latitude := $quake.geometry.coordinates[[2]]
        where $latitude gt 0.0
        return $quake
    for $quake1 in $northern_earthquakes
    where empty(for $quake2 in $northern_earthquakes
                where $quake2.properties.mag gt $quake1.properties.mag
                return $quake2)
    return
        { place: $quake1.properties.place, mag: $quake1.properties.mag }
:)


(: Variant 3: based on ordering and positional lookup :)

(:
let $earthquakes := json-doc("earthquakes.json")
return
    (: all earthquakes in the northern hemisphere :)
    let $northern_earthquakes :=
        for $quake in members($earthquakes.features)
          let $latitude := $quake.geometry.coordinates[[2]]
        where $latitude gt 0.0
        return $quake
    let $worst_earthquake :=
        (for $quake in $northern_earthquakes
         order by $quake.properties.mag descending
         return $quake)[1]
    return { place: $worst_earthquake.properties.place,
             mag:   $worst_earthquake.properties.mag }
:)

