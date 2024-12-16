# command line based updater
```
$ sudo -u www-data php /var/www/nextcloud/updater/updater.phar
Nextcloud Updater - version: vxx.0.0-44

Current version is xx.0.2.

Update to Nextcloud xx.0.4 available. (channel: "stable")
Following file will be downloaded automatically: https://download.nextcloud.com/server/releases/nextcloud-xx.0.4.zip
(...)
Start update? [y/N] y

[✔] Check for expected files
[✔] Check for write permissions
[✔] Create backup
[✔] Downloading
[✔] Verify integrity
[✔] Extracting
[✔] Enable maintenance mode
[✔] Replace entry points
[✔] Delete old files
[✔] Move new files in place
[✔] Done

Update of code successful.

Should the "occ upgrade" command be executed? [Y/n] y
(...)

Update successful
Maintenance mode is kept active
Resetting log level

Keep maintenance mode active? [y/N] n
Maintenance mode disabled

Maintenance mode is disabled

```

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