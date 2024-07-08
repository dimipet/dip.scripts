# Create folder 
```
$ sudo mkdir /var/www/nextcloud/data/my-user-name/files/my-new-folder 
$ sudo  chown www-data:www-data /var/www/nextcloud/data/my-user-name/files/my-new-folder 
$ sudo -u www-data php occ files:scan --path="/my-username>/files" 
```
