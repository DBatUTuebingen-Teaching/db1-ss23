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

### Data Model Tabular

 - `project.py`: Basic PyQL example (requires Python module `DB1`, see `material/DB1.py`). 

   Usage (UNIX-Shell):
   ~~~
   $ python3 project.py
   ~~~

- `worst-northern-quake-mag.py`: Magnitude of the worst earthquake on the northern hemisphere. PyQL query, reads `earthquakes.csv`.

- `worst-northern-quake-mag-place.jq`: Magnitude _and location_ of the worst earthquake on the northern hemisphere. PyQL query, reads `earthquakes.csv`.

- `contains.csv`, `bricks.csv`, `minifigs.csv`: CSV files, containing an excerpt
  of the LEGO mini-world database (read by the PyQL queries in this directory).

### Relational Data Model

- `bricks-no-header.csv`: CSV file (data rows only, no header row) ready
  for the import via `\COPY` into SQL table `bricks` (read by `Pg-load.bricks.sql`).

- `bricks-no-header-mangled.csv`: ⚠️ Mangled version of `bricks-no-header.csv`,
  leads to an error if imported via `\COPY`.

- `Pg-load-bricks.sql`: Create a new SQL table `bricks` via `CREATE TABLE`,
  import data rows in `bricks-no-header.csv` into table `bricks` via `\COPY`.

  Usage (UNIX-Shell):
  ~~~
  $ psql -d ‹database› -f Pg-load-bricks.sql
  ~~~

  Usage (PostgreSQL-Shell `psql`):
  ~~~
  =# \i Pg-load-bricks.sql
  […]
  =# TABLE bricks;
  ~~~


### Simple PyQL Query Optimization

Run the PyQL queries below using your Python3 interpreter in the shell, optionally use `time` to
perform timing:

~~~
$ time python3 weight-of-set5610-baseline.py
22.459999958
________________________________________________________
Executed in    4.68 secs   fish           external
   usr time    4.43 secs  110.00 micros    4.43 secs
   sys time    0.09 secs  1595.00 micros    0.09 secs
~~~

- `weight-of-set5610-baseline.py`: PyQL query, implements a straightforward nested-loop iteration
  over tables `contains` and `bricks`/`minifigs`.

    - `weight-of-set5610-key.py`: PyQL query, exploits uniqueness constraints to optimize the baseline query.
    - `weight-of-set5610-temp.py`: two-phase PyQL query, builds a temporary data structure (hash table `quantity`)
      to optimize the baseline query

 - Two (almost identical) PyQL queries, demonstrating data independence:
   1. `weight-of-set5610-pieces-list.py`: constructs a temporary `pieces` list
   2. `weight-of-set5610-pieces-tables.py`: reads from a persistent `pieces` table `pieces.csv` (this CSV flle has been
      derived from `bricks.csv` and `minifigs.csv`, see the slides).