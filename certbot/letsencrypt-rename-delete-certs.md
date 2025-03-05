## delete a certificate

find name of certificate
```
$ sudo certbot certificates
Found the following certs:
  Certificate Name: www.example.com
  ...
```
delete cert
```
$ sudo certbot delete --cert-name www.example.com
...
Are you sure you want to delete the above certificate(s)?
- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
(Y)es/(N)o: y
Deleted all files relating to certificate www.example.com.
```

disable only all ssl sites that use the cert
```
$ sudo a2dissite www.example.com-le-ssl.conf
$ sudo a2dissite www.dimipet.com-le-ssl.conf
```

backup sites confs
```
$ sudo cp /etc/apache2/sites-available/www.example.com-le-ssl.conf ~/tmp
$ sudo cp /etc/apache2/sites-available/www.dimipet.com-le-ssl.conf ~/tmp
```

delete ssl site confs
```
$ sudo rm /etc/apache2/sites-available/www.example.com-le-ssl.conf
$ sudo rm /etc/apache2/sites-available/www.dimipet.com-le-ssl.conf
```

restart apache
```
$ sudo systemctl restart apache2.service
```

## issue new certificate with new name
prepare port for certbot
```
$ sudo ufw allow 80
```
issue new cert with new name and two domains
```
$ sudo certbot --apache --cert-name www.dimipet.com -d www.dimipet.com -d  www.example.com
```

diff old and new conf to find differences
```
$ diff ~/tmp/old.cert /etc/apache2/sites-available/www.dimipet.com-le-ssl.conf
```

paste differences and make adjustments in new cert
```
$ sudo vim /etc/apache2/sites-available/www.dimipet.com-le-ssl.conf

restart apache and close 80 port
```
$ sudo systemctl restart apache2.service
$ sudo ufw delete allow 80

```
## refs
https://eff-certbot.readthedocs.io/en/stable/using.html#deleting-certificates