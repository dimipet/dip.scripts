# postgres utility scripts

## postgres-list-ports-used.sh
Shows ports used by side-by-side server installations.

`dimipet@host:~$ sudo postgres-list-ports-used.sh`

## postgres-backup-data-dir.sh 
Moves postgresql 10 data directory to new server via ftps.

This simple script stops postgresql server, compresses postgres data dir and ftps it to remote server. 
Server is restarted before ftp.

* Script uses a properties file (one is supplied as an example).
* Properties file must be supplied as cli argument.
* Properties file key-value pairs are self explanatory and you should fill them according to your needs.
* You must be root to run this script.

`dimipet@host:~$ sudo move-postgres-10.sh /some/path/of/move-postgres-10.properties`

