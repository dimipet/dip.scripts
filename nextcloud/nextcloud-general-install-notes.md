# install nextcloud under /var/www/subdirectory
if you serve nextcloud under directory `subdir` make sure 

  * in `config.php` i.e. don't add `subdir` in `overwrite.cli.url` 
  * setup `.htaccess` of webroot `/var/www/.htaccess`

`config.php`
```
  array (
    0 => 'cloud.mydomain.name' 
  ),
  (....)
  'overwrite.cli.url' => 'https://cloud.mydomain.name/',
```

`.htaccess`
```
<IfModule mod_rewrite.c>
  RewriteEngine on
  RewriteRule ^\.well-known/carddav /subdir/remote.php/dav [R=301,L]
  RewriteRule ^\.well-known/caldav /subdir/remote.php/dav [R=301,L]
  RewriteRule ^\.well-known/webfinger /subdir/index.php/.well-known/webfinger [R=301,L]
  RewriteRule ^\.well-known/nodeinfo /subdir/index.php/.well-known/nodeinfo [R=301,L]
</IfModule>

```

# service discovery calDAV/cardDAV
If your nextcloud installation is located under a folder e.g. `subdir` like `/var/www/subdir` and not in root `/var/www`   
Don't use `/etc/apache2/sites-enabled/some.conf` files to configure calDAV/cardDAV.  
Instead use `/var/www/subdir/.htaccess` and make sure these are added under `mod_rewrite.c`
```
$ sudo -u www-data vim /var/www/subdir/.htaccess
<IfModule mod_rewrite.c>
  RewriteEngine on
  RewriteRule ^\.well-known/carddav /subdir/remote.php/dav [R=301,L]
  RewriteRule ^\.well-known/caldav /subdir/remote.php/dav [R=301,L]
  RewriteRule ^\.well-known/webfinger /subdir/index.php/.well-known/webfinger [R=301,L]
  RewriteRule ^\.well-known/nodeinfo /subdir/index.php/.well-known/nodeinfo [R=301,L]
</IfModule>
```

# nextcloud cron jobs
run every 5 minutes
```
$ sudo -u www-data crontab -e
*/5  *  *  *  * php -f /var/www/subdir/cron.php
```