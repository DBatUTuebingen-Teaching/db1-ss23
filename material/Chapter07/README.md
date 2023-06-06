## Usage Notes

- `foreign-keys.sql`: Reads the CSV files to build
  a scratch copy (excerpt only) of the LEGO database.  You need
  to adapt the three file path specifications in the `\COPY` commands.

  ⚠️ Make sure to connect to a fresh/scratch/throwaway database so that you
  **do not ruin your original LEGO database**.

- `referential-integrity.sql`: Run this *after* `foreign-keys.sql` has  
  done its job.

