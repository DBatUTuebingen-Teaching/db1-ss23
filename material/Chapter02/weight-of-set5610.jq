(: Compute the overall weight of all pieces in
   LEGO set 5610-1 ("Builder")
:)

let $set5610 := json-doc("set5610-1.json")
return
  sum(for $piece in members($set5610.pieces)
      return $piece.quantity * $piece.weight)
