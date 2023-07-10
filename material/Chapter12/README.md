## Usage Notes

- The Python `*.py` files in this directory (execute with Python 3)
  rely on the `DB1.py` module (see the top-level `material/` directory).

  Usage (UNIX-Shell):
  ~~~
  $ python3 ‹file›.py
  ~~~

- Files `sets-small.csv`, `contains-small.csv`, `bricks-small.csv` contain 
  cut down versions of the original LEGO database tables.  Used by some of
  the algebraic PyQL queries to reduce query processing times.

- List of algebraic operators in module `DB1` (use Python's
  `lambda` to formulate predicates `p` and projection lists `ℓ`):

  - selection (`σ[p](r)`): `select(p, r)` 
  - projection (`π[ℓ](r)`): `project(ℓ, r)` 
  - Cartesian product (`r1 × r2`): `cross(r1, r2)`
  - θ-join (`r1 ⋈[p] r2`): `join(p, r1, r2)`
  - natural join (`r1 ⋈ r2`): `natjoin(r1, r2)`
  - union (`r1 ∪ r2`): `union(r1, r2)`
  - difference (`r1 \ r2`): `difference(r1, r2)`

