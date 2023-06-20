## Usage Notes

- `instructions.sql`: Execute this file while you are connected to the LEGO database 
  to create a new table `instructions` (representing LEGO instruction booklets).

  ⚠️ This SQL file reads the PNGs `instructions-*-9495.png`.  Edit the SQL file to
  provide the **absolute paths** to these PNG files.

- `extract-instructions-image.sql`: Run this file from your UNIX/Windows shell  
  as follows:

  ~~~
  $ psql -Xqf extract-instructions-image.sql
  ~~~

  The resulting **long** base64 string (of the form `iVBORw0KGgoAAAANSUhEUgAA...`)
  can then be transformed back into the original PNG image it represents.  A web-based
  base64 decoder is available on the web at https://base64.guru/converter/decode/image.
  Simple copy & paste the base64 string there.





