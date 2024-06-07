Create one directory per virtual host to server files from
```
$ sudo mkdir -p /var/www/portal.dimipet.com/public_html
$ sudo mkdir -p /var/www/api.dimipet.com/public_html
```

Change permissions
```
$ sudo chown -R $USER:$USER /var/www/portal.dimipet.com
$ sudo chown -R $USER:$USER /var/www/api.dimipet.com
$ sudo chmod -R 755 /var/www
```

Create some dummy content on each virtual host
```
$ nano /var/www/portal.dimipet.com/public_html/index.html
<html>
  <head>
    <title>Welcome to portal.dimipet.com</title>
  </head>
  <body>
    <h1>Success! The portal.dimipet.com virtual host is working!</h1>
  </body>
</html>
```
```
$ nano /var/www/api.dimipet.com/public_html/index.html
<html>
  <head>
    <title>Welcome to api.dimipet.com</title>
  </head>
  <body>
    <h1>Success! The api.dimipet.com virtual host is working!</h1>
  </body>
</html>
```
Create (copy) some configuration for each virtual host
```
$ sudo cp /etc/apache2/sites-available/000-default.conf /etc/apache2/sites-available/portal.dimipet.com.conf
$ sudo cp /etc/apache2/sites-available/000-default.conf /etc/apache2/sites-available/api.dimipet.com.conf
```

Configure each virtual host as follows
```
$ sudo nano /etc/apache2/sites-available/portal.dimipet.com.conf
<VirtualHost *:80>
    ServerAdmin webmaster@dimipet.com
    ServerName portal.dimipet.com
    ServerAlias www.portal.dimipet.com
    DocumentRoot /var/www/portal.dimipet.com/public_html
    ErrorLog ${APACHE_LOG_DIR}/error.log
    CustomLog ${APACHE_LOG_DIR}/access.log combined
</VirtualHost>
```

```
$ sudo nano /etc/apache2/sites-available/api.dimipet.com.conf 
<VirtualHost *:80>
    ServerAdmin webmaster@dimipet.com
    ServerName api.dimipet.com
    ServerAlias www.api.dimipet.com
    DocumentRoot /var/www/api.dimipet.com/public_html
    ErrorLog ${APACHE_LOG_DIR}/error.log
    CustomLog ${APACHE_LOG_DIR}/access.log combined
</VirtualHost>
```

Enable virtual hosts
```
$ sudo a2ensite portal.dimipet.com.conf 
Enabling site portal.dimipet.com.
To activate the new configuration, you need to run:
  systemctl reload apache2
```
```
$ sudo a2ensite api.dimipet.com.conf
Enabling site api.dimipet.com.
To activate the new configuration, you need to run:
  systemctl reload apache2
```

Disable default configuarion
```
$ sudo a2dissite 000-default.conf
Site 000-default disabled.
To activate the new configuration, you need to run:
  systemctl reload apache2
```

Restart and check
```
$ sudo systemctl restart apache2
$ sudo systemctl status apache2
● apache2.service - The Apache HTTP Server
     Loaded: loaded (/lib/systemd/system/apache2.service; enabled; vendor preset: enabled)
     Active: active (running) since Thu 2023-01-21 02:01:55 EEST; 
       Docs: https://httpd.apache.org/docs/2.4/
    Process: 3456 ExecStart=/usr/sbin/apachectl start (code=exited, status=0/SUCCESS)
   Main PID: 3588 (apache2)
      Tasks: 55 (limit: 9387)
     Memory: 5.3M
        CPU: 63ms
     CGroup: /system.slice/apache2.service
             ├─3588 /usr/sbin/apache2 -k start
             ├─3589 /usr/sbin/apache2 -k start
             └─3590 /usr/sbin/apache2 -k start
Jan 25 01:02:34 ubuntuserver06 systemd[1]: Starting The Apache HTTP Server...
Jan 25 01:02:34 ubuntuserver06 apachectl[3426]: AH00558: apache2: Could not reliably determine the server's fully qualified domain name, using ...>
Jan 25 01:02:34 ubuntuserver06 systemd[1]: Started The Apache HTTP Server.
```

Go ahead and check with your browser

