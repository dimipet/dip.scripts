# ubuntu install postgres 10
```
$ sudo apt install postgresql postgresql-contrib 
$ sudo systemctl disable postgresql 
$ sudo -u postgres psql -c "SELECT version();" 
version                                                                
------------------------------------------------------------------------------------------------------------------------------------- 
PostgreSQL 10.7 (Ubuntu 10.7-0ubuntu0.18.04.1) on x86_64-pc-linux-gnu, compiled by gcc (Ubuntu 7.3.0-27ubuntu1~18.04) 7.3.0, 64-bit 
```

## user postgres 
>*"... As with any server daemon that is accessible to the outside world, it is advisable to run PostgreSQL under a separate user account. This user account should only own the data that is managed by the server, and should not be shared with other daemons. (For example, using the user nobody is a bad idea.) In particular, it is advisable that this user account not own the PostgreSQL executable files, to ensure that a compromised server process could not modify those executables.Pre-packaged versions of PostgreSQL will typically create a suitable user account automatically during package installation."*
[[6]\]
  
> *"...the default Postgres user neither requires nor uses a password for authentication"*
[[5]\]

Don't confuse linux user `postgres` with a probable db user/role `postgres`  
Use the linux user `postgres` to connect to your server by using  
```
$ sudo -u postgres psql
psql (10 (Ubuntu...))
Type "help" for help.
```
If you need a `postgres` user shell
```
$ sudo -u postgres -i 
```
 
## create role (user)
```
$ sudo -u postgres psql
postgres=# CREATE ROLE myuser WITH LOGIN ENCRYPTED PASSWORD '1234'; 
postgres=# \password myuser
postgres=# SELECT * FROM pg_roles; 
``` 

## create DB for utf8/gr 
```
$ sudo -u postgres psql
postgres=# CREATE DATABASE mydb WITH ENCODING 'UTF-8' LC_COLLATE='el_GR.UTF-8' LC_CTYPE='el_GR.UTF-8' TEMPLATE=template0; 
postgres=# \l 

                                  List of databases 

   Name    |  Owner   | Encoding |   Collate   |    Ctype    |   Access privileges    

-----------+----------+----------+-------------+-------------+----------------------- 

dvdrental | postgres | UTF8     | en_US.UTF-8 | en_US.UTF-8 |  

mydb      | postgres | UTF8     | el_GR.UTF-8 | el_GR.UTF-8 |  

postgres  | postgres | UTF8     | en_US.UTF-8 | en_US.UTF-8 |  

template0 | postgres | UTF8     | en_US.UTF-8 | en_US.UTF-8 | =c/postgres          + 

```
## grant db privileges to role 
```
postgres=# GRANT ALL PRIVILEGES ON DATABASE mydb TO myuser; 
GRANT 
```
## change db owner
```
postgres=# ALTER DATABASE mydb OWNER TO myuser; 
postgres=# SELECT * FROM pg_roles; 
```
## create read only user
```
postgres=# CREATE ROLE user67 LOGIN PASSWORD 'yyy';
postgres=# GRANT CONNECT ON DATABASE mydb TO user67;
postgres=# GRANT USAGE ON SCHEMA public TO user67;
```
then choose what he can select on database level
```
postgres=# GRANT SELECT ON DATABASE mydb TO user67;
postgres=# GRANT SELECT ON ALL TABLES IN SCHEMA public TO user67;
```
or connect to database you want and choose on table level to grant priveleges
```
postgres=# \connect mydb 
mydb=# GRANT SELECT ON mytable1 TO user67;
mydb=# GRANT SELECT ON mytable2 TO user67;

```

## tablespaces 

> A tablespace is a location on disk (e.g. c:\tablespaces\mydb\ ) where PostgreSQL stores data files containing database objects e.g., indexes., and tables. PostgreSQL uses a tablespace to map a logical name to a physical location on disk. PostgreSQL comes with two default tablespaces:  
> pg_default tablespace stores all user data.  
> pg_global tablespace stores all global data. 
[[2]\]

To create a new tablespace
```
CREATE TABLESPACE tablespace_name 
OWNER user_name 
LOCATION directory_path; 
```

## create table with `id`
```
CREATE TABLE table_name( 
    id SERIAL
); 
```
is equivalent to the following statements: 
```
CREATE SEQUENCE table_name_id_seq; 
CREATE TABLE table_name ( 
    id integer NOT NULL DEFAULT nextval('table_name_id_seq') 
); 
ALTER SEQUENCE table_name_id_seq 
OWNED BY table_name.id; 
```

## create sample table + sequence 
```
CREATE SEQUENCE test_id_seq ; 
CREATE TABLE test ( 
    id integer PRIMARY KEY NOT NULL DEFAULT nextval('test_id_seq'), 
    info varchar(40) 
);  

ALTER SEQUENCE test_id_seq OWNED BY test.id; 

CREATE SEQUENCE login_id_seq start 10000 INCREMENT BY 1 NO MINVALUE NO MAXVALUE CACHE 1; 

CREATE TABLE login ( 
  id integer PRIMARY KEY NOT NULL DEFAULT nextval('login_id_seq'), 
  username varchar(32) NOT NULL, 
  email varchar(128) DEFAULT NULL, 
  pwd varchar(255) NOT NULL, 
  salary REAL, 
  join_date DATE 
); 

ALTER SEQUENCE login_id_seq OWNED BY login.id; 

INSERT INTO COMPANY (username, email, pwd, salary, join_date) VALUES ('paul', 'paul@gmail.com', '123456', 20000.00,'2017-08-13'); 
```
## schema  
> is a named collection of tables. A schema can also contain views, indexes, sequences, data types, operators, and functions. Schemas are analogous to directories at the operating system level, except that schemas cannot be nested. PostgreSQL statement CREATE SCHEMA creates a schema. 

## cluster
> Before you can do anything, you must initialize a database storage area on disk. We call this a database cluster. (The SQL standard uses the term catalog cluster.) A database cluster is a collection of databases that is managed by a single instance of a running database server. After initialization, a database cluster will contain a database named postgres, which is meant as a default database for use by utilities, users and third party applications. The database server itself does not require the postgres database to exist, but many external utility programs assume it exists. There are two more databases created within each cluster during initialization, named template1 and template0. As the names suggest, these will be used as templates for subsequently-created databases; they should not be used for actual work. (See Chapter 23 for information about creating new databases within a cluster.)
[[7]\]

# psql shortcuts
```
\q          Quit 
\d          List tables/relations 
\l          List databases 
\du         List roles (users) 
\c mydb     Use database mydb
```
show version
```
SELECT version();        
```
show all users 
```
SELECT * from pg_catalog.pg_user;"
```

# References
[1]: https://hostadvice.com/how-to/how-to-install-postgresql-database-server-on-ubuntu-18-04/ 
[2]: http://www.postgresqltutorial.com/ 
[3]: https://www.postgresql.org/docs/10/ 
[4]: https://medium.com/coding-blocks/creating-user-database-and-adding-access-on-postgresql-8bfcd2f4a91e 
[5]: https://www.atlassian.com/data/admin/how-to-set-the-default-user-password-in-postgresql
[6]: https://www.postgresql.org/docs/current/postgres-user.html
[7]: https://www.postgresql.org/docs/current/creating-cluster.html

[1] https://hostadvice.com/how-to/how-to-install-postgresql-database-server-on-ubuntu-18-04/ 
[2] http://www.postgresqltutorial.com/ 
[3] https://www.postgresql.org/docs/10/ 
[4] https://medium.com/coding-blocks/creating-user-database-and-adding-access-on-postgresql-8bfcd2f4a91e 
[5] https://www.atlassian.com/data/admin/how-to-set-the-default-user-password-in-postgresql
[6] https://www.postgresql.org/docs/current/postgres-user.html
[7] https://www.postgresql.org/docs/current/creating-cluster.html