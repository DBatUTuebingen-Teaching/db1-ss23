## Usage Notes

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

- `contains.csv`, `bricks.csv`, `minifigs.csv`: CSV files, containing an excerpt
  of the LEGO mini-world database (read by the PyQL queries in this directory).

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
      to optimize the baseline query/
    - `weight-of-set5610-par.py`: two-phase PyQL query, parallelizes the iteration over tables `bricks` and `minifigs`
      (no significant performance advantage for this particular sample query problem).
     
 - Two (almost identical) PyQL queries, demonstrating data independence:
   1. `weight-of-set5610-pieces-list.py`: constructs a temporary `pieces` list
   2. `weight-of-set5610-pieces-tables.py`: reads from a persistent `pieces` table `pieces.csv` (this CSV flle has been
      derived from `bricks.csv` and `minifigs.csv`, see the slides).
     
