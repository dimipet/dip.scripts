# install
```
$ sudo apt install sqlite3
```
# open db
```
$ sqlite3
SQLite version 3.31
Enter ".help" for usage hints.
sqlite> .open some.db
```

# create db
```
$ sqlite3 auth.db
SQLite version 3.31
Enter ".help" for usage hints.
sqlite> 
```
# create table
```
sqlite> CREATE TABLE users (                                                                                                    
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    username TEXT NOT NULL UNIQUE,
    password TEXT NOT NULL
);
```
# drop table
```
sqlite> DROP TABLE users;
```

# password hash bcrypt
be sure to escape \ chars like `# > !` etc.
```
$ sudo snap install bcrypt-tool
$ bcrypt-tool hash password1 12
$2a$12...Ka32i
```
# insert
```
INSERT INTO users (username, password) VALUES ('user1', '$2a$12...Ka32i');
```
# quit
```
sqlite> .quit
```


