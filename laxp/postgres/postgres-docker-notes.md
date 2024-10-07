# pull & run
```
$ docker run --name my-postgres -p 5432:5432 -e POSTGRES_PASSWORD=my-password -d postgres:14.13-bullseye

$ docker ps
CONTAINER ID   IMAGE                     COMMAND                  CREATED         STATUS         PORTS                    NAMES
73da972701f7   postgres:14.13-bullseye   "docker-entrypoint.s…"   5 seconds ago   Up 3 seconds   0.0.0.0:5432->5432/tcp   my-postgres


$ netstat -ant | grep 5432
tcp6       0      0 :::5432                 :::*                    LISTEN
```
# connect
```
$ psql -h localhost -p 5432 -U postgres
postgres=# \l
```

or
```
$ psql postgresql://postgres:5432@localhost:5432/postgres
```
# get shell inside container
```
docker exec -it 73da972701f7 bash
root@73da972701f7:/# psql -U postgres
postgres-# CREATE DATABASE mydb;
postgres-# \q
```

# create db and role
```
$ psql -h localhost -p 5432 -U postgres
postgres=# CREATE DATABASE mydb WITH ENCODING='UTF-8' LC_COLLATE 'en_US.UTF-8' LC_CTYPE 'en_US.UTF-8' TEMPLATE=template0;
postgres=# DROP ROLE IF EXISTS myuser;
postgres=# CREATE ROLE someuser WITH LOGIN ENCRYPTED PASSWORD 'someuser_strong_password';
postgres=# GRANT ALL PRIVILEGES ON DATABASE mydb TO someuser;
postgres=# ALTER DATABASE mydb OWNER TO someuser;
postgres=# \q
$ docker cp /path/to/dev-database.dump <container_id_or_name>:/tmp/dev-database.dump
$ docker exec -it <container_id_or_name> pg_restore -U postgres -d mydb -Fc /tmp/dev-database.dump

$ sudo -u postgres psql --set ON_ERROR_STOP=on -d mydb -f ./my-dump-file
```
