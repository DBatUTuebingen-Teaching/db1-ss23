#! /bin/sh

# Extract a DNA subsequence (specified by location range) from a GenBank entry
# Usage:
#   extract-dna-sequence ⟨from⟩ ⟨to⟩

# Expects DNA origin sequence to adhere to the format:
# ORIGIN
#    ⟨offset⟩ ⟨amino acids⟩ ⟨amino acids⟩ ...
#    ...
# //

FROM=$1
TO=$2

awk '
  BEGIN               { ORS = ""; dna = 0; seq = "" }
  /ORIGIN/            { dna = 1 }
  dna && /^ *[0-9]+/  { for (i = 2; i <= NF; i++)
                          seq = seq $i
                      }
  /\/\//              { dna = 0 }
  END                 { print seq }
' |
cut -c $FROM-$TO
