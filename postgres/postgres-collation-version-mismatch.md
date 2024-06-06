when you get warning e.g. in postgres 16
```
WARNING:  database "postgres" has a collation version mismatch
DETAIL:  The database was created using collation version 2.31, 
but the operating system provides version 2.35.
HINT:  Rebuild all objects in this database that use the default 
collation and run 
ALTER DATABASE postgres REFRESH COLLATION VERSION, 
or build PostgreSQL with the right library version.
psql (16.1 (Ubuntu 16.1-1.pgdg20.04+1))
Type "help" for help.
```
do the following (use port -p that the server listens on )
```
$ sudo -u postgres psql -p 5439
WARNING:  database "postgres" has a collation version mismatch
DETAIL:  The database was created using collation version 2.31, but the operating system provides version 2.35.
HINT:  Rebuild all objects in this database that use the default collation and run ALTER DATABASE postgres REFRESH COLLATION VERSION, or build PostgreSQL with the right library version.
psql (16.1 (Ubuntu 16.1-1.pgdg20.04+1))
Type "help" for help.

postgres=# ALTER DATABASE postgres REFRESH COLLATION VERSION;
NOTICE:  changing version from 2.31 to 2.35
ALTER DATABASE
postgres=# \q
```
