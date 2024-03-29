#!/bin/bash

####################################################
#
# Simple tgz backup of /etc /root /var with usual dir 
# exclusions and delete of 30+ days older backups
#
####################################################

# get year then use it as directory
YEAR=$(date +%Y)

FILENAME=$(date +%Y%m%d-%H%M%S)_backup.tgz 
DIR2BACKUP=/mnt/some/path/to


# check if year subdir exist else create
if [ -d "$DIR2BACKUP/$YEAR" ]; then
	echo "$DIR2BACKUP/$YEAR" exists
else
	echo "$DIR2BACKUP/$YEAR" does not exist
	echo ... creating directory ...
	mkdir "$DIR2BACKUP/$YEAR"
fi

tar -c  --exclude=/var/cache --exclude=/var/lib --exclude=/etc/gconf \
--exclude=/etc/selinux --exclude=/root/.mozilla --exclude=/root/.evolution \
--exclude=/root/.thumbnails --exclude=/var/www/svn --exclude=/root/.Trash \
--exclude=/var/tmp --exclude=/var/games --exclude=/var/db --exclude=/var/run \
--exclude=/var/local --exclude=/var/www \
-vpzf "$DIR2BACKUP/$YEAR/$FILENAME" /root /etc /var/ 

# delete 30+ days old
find "$DIR2BACKUP/$YEAR" -name "*.tgz" -type f -mtime +30 -delete



