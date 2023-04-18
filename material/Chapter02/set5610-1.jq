let $set5610 := { "set": "5610-1",
                  "pieces": [ { "brick": "6157",  "quantity": 1 },
                              { "brick": "3139",  "quantity": 2 },
                              { "brick": "3839b", "quantity": 1 } ] }
return
  $set5610.pieces[[2]].brick
