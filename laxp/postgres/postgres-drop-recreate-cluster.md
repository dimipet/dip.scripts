WARNING DATA LOSS

cluster = server

when doing upgrades, in case something goes wrong in target cluster (e.g. upgrade from source 10 to target 14) delete it and start over

Stop target service
```
$ sudo systemctl stop postgresql@14-main
```
List available clusters 
```
$ pg_lsclusters
Ver Cluster Port Status Owner    Data directory              Log file
14  main    5432 down   postgres /var/lib/postgresql/14/main /var/log/postgresql/postgresql-14-main.log
```

Drop target cluster
```
$ sudo pg_dropcluster --stop 14 main
Removed /etc/systemd/system/multi-user.target.wants/postgresql@14-main.service.
```

Create new target cluster
```
$ sudo pg_createcluster --start 14 main
Creating new PostgreSQL cluster 14/main ...
/usr/lib/postgresql/14/bin/initdb -D /var/lib/postgresql/14/main --auth-local peer --auth-host scram-sha-256 --no-instructions
The files belonging to this database system will be owned by user "postgres".
This user must also own the server process.

The database cluster will be initialized with locales
  COLLATE:  en_US.UTF-8
  CTYPE:    en_US.UTF-8
  MESSAGES: en_US.UTF-8
  MONETARY: el_GR.UTF-8
  NUMERIC:  el_GR.UTF-8
  TIME:     el_GR.UTF-8
The default database encoding has accordingly been set to "UTF8".
The default text search configuration will be set to "english".

Data page checksums are disabled.

fixing permissions on existing directory /var/lib/postgresql/14/main ... ok
creating subdirectories ... ok
selecting dynamic shared memory implementation ... posix
selecting default max_connections ... 100
selecting default shared_buffers ... 128MB
selecting default time zone ... Europe/Athens
creating configuration files ... ok
running bootstrap script ... ok
performing post-bootstrap initialization ... ok
syncing data to disk ... ok
Ver Cluster Port Status Owner    Data directory              Log file
14  main    5434 online postgres /var/lib/postgresql/14/main /var/log/postgresql/postgresql-14-main.log
```

ready.
