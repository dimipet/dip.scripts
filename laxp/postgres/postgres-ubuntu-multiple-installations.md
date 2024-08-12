wrapper scripts are in postgres-common package / sudo apt install postgresql-common / common for all instances - versions 

## list installed
```
$ dpkg -l | grep postgresql-common  
ii postgresql-common 201.pgdg18.10+1 all PostgreSQL database-cluster manager  
```

## list all clusters / versions installed  
> Before you can do anything, you must initialize a database storage area on disk. We call this a database cluster. (The SQL standard uses the term catalog cluster.) A database cluster is a collection of databases that is managed by a single instance of a running database server. After initialization, a database cluster will contain a database named postgres, which is meant as a default database for use by utilities, users and third party applications. The database server itself does not require the postgres database to exist, but many external utility programs assume it exists. There are two more databases created within each cluster during initialization, named template1 and template0. As the names suggest, these will be used as templates for subsequently-created databases; they should not be used for actual work. (See Chapter 23 for information about creating new databases within a cluster.)
[[2]\]

Default port 5432, other version – instances get next ports 
```
$ pg_lsclusters 
Ver Cluster Port Status Owner    Data directory              Log file 
10  main    5432 online postgres /var/lib/postgresql/10/main /var/log/postgresql/postgresql-10-main.log 
12  main    5433 online postgres /var/lib/postgresql/12/main /var/log/postgresql/postgresql-12-main.log 
13  main    5434 online postgres /var/lib/postgresql/13/main /var/log/postgresql/postgresql-13-main.log 
14  main    5435 online postgres /var/lib/postgresql/14/main /var/log/postgresql/postgresql-14-main.log 
```

## configuration files 
```
$ ls -R /etc/postgresql 
/etc/postgresql: 
10  12  13  14 
{…} 
{…}  
```
## pg_ctlcluster (wrapper of pg_ctl) 
```
$ sudo pg_ctlcluster 10 main status 
pg_ctl: server is running (PID: 1366) 
/usr/lib/postgresql/10/bin/postgres "-D" "/var/lib/postgresql/10/main" "-c" "config_file=/etc/postgresql/10/main/postgresql.conf" 
```

## start stop by version
```
$ sudo systemctl stop postgresql@10-main  
$ sudo systemctl start postgresql@14-main  
```

## create add start reload stop 
```
$ sudo pg_createcluster 11 standby1  
{....}  
$ sudo pg_ctlcluster 11 standby1 start  
$ sudo systemctl daemon-reload  
$ pg_ctlcluster 11 anotherdb start  
$ pg_ctlcluster 11 anotherdb stop  
```

or  
```
$ sudo systemctl stop postgresql@11-anotherdb  


## create new cluster
```
$ pg_createcluster 10 pg10newdb  
```
 

## list 
```
$ pg_lsclusters  
```

# references 
[1]: https://dzone.com/articles/managing-multiple-postgresql-instances-on-ubuntude  
[2]: https://www.postgresql.org/docs/current/creating-cluster.html

[1] https://dzone.com/articles/managing-multiple-postgresql-instances-on-ubuntude  
[2] https://www.postgresql.org/docs/current/creating-cluster.html
