# ubuntu installation
```
$ sudo apt install mysql-server
$ sudo systemctl start mysql.service
$ sudo systemctl enable mysql.service
$ sudo mysql

ALTER USER 'root'@'localhost' IDENTIFIED WITH mysql_native_password BY 'a-strong-password';
exit

```
now you can proceed with out issues with
```
sudo mysql_secure_installation
```
