# find php.ini in use from nextcloud

- head to https://myserver.dimipet.com/index.php/settings/admin/serverinfo
- check PHP version

# find php.ini in use from cli
```
$ php --ini
```

# login temporary error
```
$ sudo vim /path/to/my/php.ini/file
upload_max_filesize=200M        # do not use G, instead of 2G use 2000M
post_max_size=200M              # do not use G, instead of 2G use 2000M
$ sudo systemctl restart apache2.service
```

https://github.com/nextcloud/server/issues/43301

# big size of nextcloud directory
```
$ sudo apt-get install ncdu
$ ncdu
```

# apache server js.map files
you get error
```
Your webserver is not set up to serve `.js.map` files.   
Without these files, JavaScript Source Maps won't function properly, 
making it more challenging to troubleshoot and debug any issues that may arise.
```
check you get 200 OK when when
```
$ curl -I https://mydomain.name/apps/settings/js/map-test.js.map
```

# cron job cli, .ocdata in root folder
you get message 
```
The cron job could not be run via the CLI. The following technical errors appeared:
     The data folder is invalid Make sure there is an ".ocdata" file in the root of the data folder.
```
solve it with 
```
$ sudo -u www-data touch /var/www/nextcloud/data/.ocdata

```