# Ubuntu Server PHP Installation

Sometimes we need to move web apps from a remote to a local server, or any two servers. As such we need to have both (remote and local) servers in sync. i.e. have the same installations and deployments. 

In this article we deal with PHP installations for Ubuntu Servers and specifically about **nextcloud** installations, however it should fit almost all cases. By default Ubuntu Server 20.04 LTS provides `php7.4` and Ubuntu Server 22.04 LTS provides `php8.1`. 

We need both side by side. If you need only one php version read the **Default** installations below, otherwise if you need both read the **Preferred** method which enables the use of external repository.

## Default Ubuntu Server 20.04/22.04 LTS installations and uninstallations

### Default php7.4 installation
In case you need default `php7.4` for Ubuntu Server 20.04 LTS it is installed as follows
```
$ sudo apt install php7.4 php7.4-cli php7.4-common php7.4-curl php7.4-zip php7.4-gd php7.4-mysql
        php7.4-xml php7.4-mbstring php7.4-json php7.4-intl php7.4-gmp php7.4-bcmath php7.4-imagick \
        php7.4-cgi php7.4-ldap php7.4-pgsql php7.4-dev libmcrypt-dev php-pear libapache2-mod-php7.4

$ sudo update-alternatives --config php         # choose 7.4

$ sudo a2enmod php7.4                           # tell apache to use php7.4

$ sudo systemctl restart apache2 && sudo systemctl status apache2
```

### Default `php8.1` installation
In case you need default php8.1 for Ubuntu Server 22.04 LTS it is installed as follows
```
$ sudo apt install php8.1 php8.1-cli php8.1-common php8.1-curl php8.1-zip php8.1-gd php8.1-mysql
        php8.1-xml php8.1-mbstring php8.1-json php8.1-intl php8.1-gmp php8.1-bcmath php8.1-imagick \
        php8.1-cgi php8.1-ldap php8.1-pgsql php8.1-dev libmcrypt-dev php-pear libapache2-mod-php8.1

$ sudo update-alternatives --config php         # choose 8.1

$ sudo a2enmod php8.1                           # tell apache to use php8.1

$ sudo systemctl restart apache2 && sudo systemctl status apache2
```
### Uninstall / purge and cleanup
If you need you may remove all usual {installations, configurations, repositories} as follows
```
$ sudo apt purge php8.1 php8.1-cli php8.1-common php8.1-curl php8.1-zip php8.1-gd php8.1-mysql
        php8.1-xml php8.1-mbstring php8.1-json php8.1-intl php8.1-gmp php8.1-bcmath php8.1-imagick \
        php8.1-cgi php8.1-ldap php8.1-pgsql php8.1-dev libmcrypt-dev php-pear libapache2-mod-php8.1

$ sudo apt purge php7.4 php7.4-cli php7.4-common php7.4-curl php7.4-zip php7.4-gd php7.4-mysql
        php7.4-xml php7.4-mbstring php7.4-json php7.4-intl php7.4-gmp php7.4-bcmath php7.4-imagick \
        php7.4-cgi php7.4-ldap php7.4-pgsql php7.4-dev libmcrypt-dev php-pear libapache2-mod-php7.4

$ sudo add-apt-repository -r ppa:ondrej/php

$ sudo systemctl restart apache2 && sudo systemctl status apache2
```

## Preferred Ubuntu Server 20.04/22.04 LTS installations and uninstallations
Install repo first
```
$ sudo add-apt-repository ppa:ondrej/php -y
```

Install `php7.4` and `php8.1` on ubuntu server 20.04/22.04
```
$ sudo add-apt-repository ppa:ondrej/php -y

$ sudo apt install php7.4 php7.4-cli php7.4-common php7.4-curl php7.4-zip php7.4-gd php7.4-mysql
        php7.4-xml php7.4-mbstring php7.4-json php7.4-intl php7.4-gmp php7.4-bcmath php7.4-imagick \
        php7.4-cgi php7.4-ldap php7.4-pgsql php7.4-dev libmcrypt-dev php-pear libapache2-mod-php7.4

$ sudo apt install php8.1 php8.1-cli php8.1-common php8.1-curl php8.1-zip php8.1-gd php8.1-mysql
        php8.1-xml php8.1-mbstring php8.1-json php8.1-intl php8.1-gmp php8.1-bcmath php8.1-imagick \
        php8.1-cgi php8.1-ldap php8.1-pgsql php8.1-dev libmcrypt-dev php-pear libapache2-mod-php8.1
```
Then choose alternative `php7.4` system wide and inform apache2
```
$ sudo update-alternatives --config php

$ sudo a2dismod php8.1 && sudo a2enmod php7.4
```

... or choose alternative `php8.1` system wide and inform apache2
```
$ sudo update-alternatives --config php

$ sudo a2dismod php7.4 && sudo a2enmod php8.1
```

Restart apache
```
$ sudo systemctl restart apache2 && sudo systemctl status apache2
```
## Check modules
Create a php file (e.g. on remote and local server) with phpinfo()
```
$ sudo touch /var/www/html/some-file.php && sudo nano /var/www/html/some-file.php
<?php
        phpinfo();
        phpinfo(INFO_MODULES);
?>
```

Check loaded modules and enable as needed so remote and local installations match
```
$ a2enmod actions cgi headers rewrite socache_shmcb a2enmod ssl
```

You can also check by running installed php modules on both servers
```
$php -m
```




