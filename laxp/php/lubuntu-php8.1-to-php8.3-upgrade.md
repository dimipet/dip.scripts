# remove ondrej php8.3
```
$ sudo add-apt-repository --remove ppa:ondrej/php
$ sudo rm -i /etc/apt/sources.list.d/ondrej-ubuntu-php-jammy.list.distUpgrade 
$ sudo rm -i /etc/apt/sources.list.d/ondrej-ubuntu-php-jammy.sources
$ sudo apt remove --purge php8.3
```

# install php8.3
```
$ sudo apt install php8.3 php8.3-cli php8.3-common php8.3-curl php8.3-zip php8.3-gd php8.3-mysql php8.3-xml php8.3-mbstring php8.3-intl php8.3-gmp php8.3-bcmath php8.3-imagick php8.3-cgi php8.3-ldap php8.3-pgsql php8.3-dev  libmcrypt-dev php-pear 
```

# install libapache or fpm module
```
$ sudo apt install libapache2-mod-php8.3
OR
$ sudo apt install php8.3-fpm && sudo a2enconf php8.3-fpm
```

# configure alternatives
```
$ sudo update-alternatives --config php
$ sudo a2dismod php8.1 && sudo a2enmod php8.3
$ sudo systemctl restart apache2 && sudo systemctl status apache2
```

# change memory_limit
```
$ grep memory_limit /etc/php/ -r
$ sudo vim /etc/php/8.3/apache2/php.ini
$ sudo vim /etc/php/8.3/cgi/php.ini
$ sudo vim /etc/php/8.3/cli/php.ini
memory_limit = 2048M
```

# change upload_max_filesize
```
$ grep upload_max_filesize /etc/php/ -r
$ sudo vim /etc/php/8.3/apache2/php.ini
$ sudo vim /etc/php/8.3/cgi/php.ini
$ sudo vim /etc/php/8.3/cli/php.ini
upload_max_filesize = 1G
```
# purge previous php
sudo apt purge php8.1*
sudo apt purge php7.4*

