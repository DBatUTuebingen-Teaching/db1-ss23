## Usage Notes

- `fdw.sql`: Demonstrates the use of PostgreSQL's _foreign data wrapper_   
  that implements a synchronization of CSV file contents and
  table state (this only goes one way: CSV → DB).

  - ⚠️ You need to replace the **two** CSV file paths `/Users/grust/.../calendar.csv` in
    this SQL file to make the example work.  
 
  - Once the _foreign data wrapper_ is set up, edits in file `calendar.csv`
    will be automagically mirrored by the state (≡ bag of rows) of table `calendar`
    (as long as the CSV data is well-formed).

  - NB: You *cannot* perform SQL DML commands (`INSERT`, `DELETE`, `UPDATE`)
    on table `calendar`.
