check state of all services
```
$ sudo systemctl status postgresql postgresql@10-main.service postgresql@11-main.service \
  postgresql@12-main.service postgresql@13-main.service postgresql@14-main.service \
  postgresql@15-main.service postgresql@16-main.service
```

use dip.scripts and note what port and dbs each cluster has, BEWARE below clusters use same port -> don't start them together.
```
$ ~/dip.scripts/postgres/postgres-list-ports-used.sh 
/etc/postgresql/12/main/postgresql.conf uses -> port = 5432
/etc/postgresql/14/main/postgresql.conf uses -> port = 5432
```

check what port each cluster uses and what dbs it has
```
$ ~/dip.scripts/postgres/postgres-list-databases-per-cluster.sh
12/main         | 12.17 (Ubuntu 12.17-1.pgdg20.04+1)     [port:5432] has these databases :     [ template0 template1 postgres my_custom_database]
```

create a log dir to work the upgrade in 
```
$ mkdir ~/postgres-upgrade-12-14
$ sudo chown postgres:postgres ~/postgres-upgrade-12-14/
$ cd ~/postgres-upgrade-12-14/
```

stop all instances 
```
$ sudo systemctl stop postgresql postgresql postgresql@10-main.service postgresql@11-main.service \
  postgresql@12-main.service postgresql@13-main.service postgresql@14-main.service \
  postgresql@15-main.service postgresql@16-main.service
```

perform upgrade 12->14
```
$ sudo -u postgres /usr/lib/postgresql/14/bin/pg_upgrade \
--old-datadir=/var/lib/postgresql/12/main \
--new-datadir=/var/lib/postgresql/14/main \
--old-bindir=/usr/lib/postgresql/12/bin \
--new-bindir=/usr/lib/postgresql/14/bin \
--old-options '-c config_file=/etc/postgresql/12/main/postgresql.conf' \
--new-options '-c config_file=/etc/postgresql/14/main/postgresql.conf'
```

change ports of target server 
```
$ sudo -u postgres nano /etc/postgresql/14/main/postgresql.conf
port = 5432
```
change port to old server if you need to start both servers at the same time
```
$ sudo -u postgres nano /etc/postgresql/12/main/postgresql.conf
port = 5433
```
start your new instance 
```
$ sudo systemctl start postgresql@14-main.service
```

fix md5 to scram password problem
```
$ sudo -u postgres psql
postgres=# ALTER ROLE myuser WITH PASSWORD 'mypassword';
```

check logs and apps and fix as needed
```
$ sudo systemctl status postgresql@14-main.service 
$ tail -f /var/log/postgresql/postgresql-14-main.log
```

if everything went well disable/enable as needed
```
$ sudo systemctl disable postgresql@12-main.service
$ sudo systemctl enable postgresql@14-main.service
```

(optional) if everything went well you can delete previous cluster with the script created automatically below
```
$ ~/postgres-upgrade-12-14$ ll
total 12
drwxrwxr-x  2 postgres postgres 4096 Ιαν   8 10:59 ./
drwxr-xr-x 12 ubuntu   ubuntu   4096 Ιαν   8 10:54 ../
-rwx------  1 postgres postgres   48 Ιαν   8 10:59 delete_old_cluster.sh*
```

(optional) uninstall purge old cluster
```
(google it)
```

