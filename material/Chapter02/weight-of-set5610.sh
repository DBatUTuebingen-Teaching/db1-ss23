#! /bin/sh

# Compute the overall weight of all pieces in LEGO set 5610-1

# NB: assumes one piece per line and input of the form:
#
#                    <quantity>x ... <weight>g ...
#
# (everything else is considered noise and skipped over)

# Notes:
# - sed command `p': print pattern space, then process next line
#               `d': delete pattern space, next line
# - can insert `tee /dev/stderr' into the pipeline to debug

sed -E -e 's/^([0-9]+)x.+[ /]([0-9.]+)g.*$/\1 \2/p; d' |

awk '
  BEGIN { sum = 0        }
  //    { sum += $1 * $2 }
  END   { print sum      }
'
