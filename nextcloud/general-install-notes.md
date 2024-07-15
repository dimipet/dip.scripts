# service discovery calDAV/cardDAV
If your nextcloud installation is located under a folder e.g. `nextcloud` like `/var/www/nextcloud` and not in root `/var/www`   
Don't use `/etc/apache2/sites-enabled/some.conf` files to configure calDAV/cardDAV.  
Instead use `/var/www/nextcloud/.htaccess` and make sure these are added under `mod_rewrite.c`
```
$ sudo -u www-data vim /var/www/nextcloud/.htaccess
<IfModule mod_rewrite.c>
  RewriteEngine on
  RewriteRule ^\.well-known/carddav /nextcloud/remote.php/dav [R=301,L]
  RewriteRule ^\.well-known/caldav /nextcloud/remote.php/dav [R=301,L]
  RewriteRule ^\.well-known/webfinger /nextcloud/index.php/.well-known/webfinger [R=301,L]
  RewriteRule ^\.well-known/nodeinfo /nextcloud/index.php/.well-known/nodeinfo [R=301,L]
</IfModule>
```
