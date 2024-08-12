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

