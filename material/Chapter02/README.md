## Usage Notes

### Data Model Text

- `GenBank-SCU49845.txt`: GenBank entry for *Baker's Yeast*.
- `set5610-1.txt`: LEGO set 5610 (Data Model Text).

- `weight-of-set5610.sh`: Overall weight of LEGO set 5610.  Shell script, based on `sed` and `awk` (Data Model Text).

  Usage (UNIX-Shell):
  ~~~
  $ weight-of-set5610.sh < set5610-1.txt
  ~~~

- `extract-dna-sequence.sh`: Extract a specfied GATC sequence from a GenBank entry.
  Shell script, based on `awk` (Data Model Text).
  
  Usage (UNIX-Shell):
  ~~~
  $ extract-dna-sequence.sh 3300 4037 < GenBank-SCU49845.txt
  ~~~

### Data Model Nested Arrays and Dictionaries

- `set5610-1.json`: LEGO set 5610 (JSON, Data Model Nested Arrays and Dictionaries).
- `set5610-1.jq`, `xsys.jq`, `grouping.jq`: basic JSONiq example

  Evaluation in RumbleDB (use RumbleDB option `--query-path ‹file›.jq` or _cut & paste_ at the RumbleDB prompt)

- `weight-of-set5610.jq`: Overall weight of LEGO set 5610. JSONiq query, reads JSON file `set5610-1.json`.
 
- `earthquakes.json`: Earthquake data provided by the US Geological Survey (JSON, Data Model Nested Arrays and Dictionaries).

- `worst-northern-quake-mag.jq`: Magnitude of the worst earthquake on the northern hemisphere. JSONiq query, reads `earthquakes.json`.

- `worst-northern-quake-mag-place.jq`: Magnitude _and location_ of the worst earthquake on the northern hemisphere. JSONiq query, reads `earthquakes.json`.

- `earthquakes-dup.json`: Earthquake data provided by the US Geological Survey, ⚠️ contains a duplicate of the magnitude 4.9 earthquake (JSON, Data Model Nested Arrays and Dictionaries).
