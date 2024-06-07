Ubuntu 22.04 server 
```
AH00558: apache2: Could not reliably determine the server's fully qualified domain name, Set the 'ServerName' directive globally to suppress this message
```

After installing apache2 and vhosts configuration you may receive error If you may receive 
`AH00558: apache2: Could not reliably determine the server's fully qualified domain name`

Reproduce as follows
```
$ sudo apachectl restart
AH00558: apache2: Could not reliably determine the server's fully qualified domain name, using 10.10.10.123. 
Set the 'ServerName' directive globally to suppress this message

$ sudo journalctl -u apache2.service
.... systemd[1]: Starting The Apache HTTP Server...
.... apachectl[2048]: AH00558: apache2: Could not reliably determine the server's fully qualified domain name, using 10.>
.... systemd[1]: Started The Apache HTTP Server.

$ sudo systemctl restart apache2
$ sudo systemctl status apache2
● apache2.service - The Apache HTTP Server
     Loaded: loaded (/lib/systemd/system/apache2.service; enabled; vendor preset: enabled)
     Active: active (running) since ..... EEST; 8s ago
     Docs: https://httpd.apache.org/docs/2.4/
     Process: 1234 ExecStart=/usr/sbin/apachectl start (code=exited, status=0/SUCCESS)
     ...
..... systemd[1]: Starting The Apache HTTP Server...
..... apachectl[...]: AH00558: apache2: Could not reliably determine the server's fully qualified domain name, using 10.>
..... systemd[1]: Started The Apache HTTP Server.
```

The solution is to add `ServerName` to `/etc/apache2/apache2.conf`
```
$ sudo nano /etc/apache2/apache2.conf
# Global configuration
#
ServerName 127.0.0.1
```

Restart apache2 and check as follows
```
$ sudo systemctl restart apache2
$ apache2ctl configtest 
Syntax OK
$ sudo journalctl -u apache2.service
$ sudo systemctl status apache2
● apache2.service - The Apache HTTP Server
     Loaded: loaded (/lib/systemd/system/apache2.service; enabled; vendor preset: enabled)
     Active: active (running) since Thu 2023-08-17 13:58:15 EEST; 11min ago
     ...
... systemd[1]: Starting The Apache HTTP Server...
... systemd[1]: Started The Apache HTTP Server.
```

