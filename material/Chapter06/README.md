## Usage Notes

- You may want to remove database connection commands like 
  `\c scratch` or `\c lego` from these SQL scripts (I use
  these commands to remind me that the examples either work
  on throwaway scratch tables or the main LEGO database).

- `correlation.py` simulates the behavior of *scalar subqueries*  
  (nested SQL subqueries that yield tables containing a single
  row holding a single column) in PyQL.

