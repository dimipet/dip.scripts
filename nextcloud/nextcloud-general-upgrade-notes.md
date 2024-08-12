# occ command not found
```
$ sudo -u www-data chmod u+x /var/www/nextcloud/occ
$ sudo -u www-data /var/www/nextcloud/occ db:add-missing-indices
```

# occ add-missing-indices
```
$ sudo -u www-data /var/www/nextcloud/occ db:add-missing-indices
```

# occ mimetypes / one or more mimetype migrations are available
```
$ sudo -u www-data /var/www/nextcloud/occ maintenance:repair --include-expensive
```

# delete updater backups
find the name of your backup folder
```
$ sudo -u www-data ls -la /var/www/nextcloud/data
drwxr-xr-x  4 www-data www-data     4096 Jun 05 20:27 updater-oxemoxe7cywk
```
folder name is `updater-oxemoxe7cywk`  

find old backups
```
$ sudo -u www-data ls -la /var/www/nextcloud/data/updater-oxemoxe7cywk/backups
drwxr-x--- 13 www-data www-data 4096 Apr   1 07:59 nextcloud-28.0.4-1234567890
drwxr-x--- 13 www-data www-data 4096 May   1 07:59 nextcloud-28.0.5-1234567890
drwxr-x--- 13 www-data www-data 4096 Jul  15 10:26 nextcloud-28.0.6-1234567890

```
keep the last and delete previous
```
$ sudo -u www-data rm -rf /var/www/nextcloud/data/updater-oxemoxe7cywk/backups/nextcloud-28.0.4-1234567890
$ sudo -u www-data rm -rf /var/www/nextcloud/data/updater-oxemoxe7cywk/backups/nextcloud-28.0.5-1234567890
```