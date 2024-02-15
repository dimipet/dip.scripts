#!/bin/bash

####################################################
#
# Simple backup of file with timestamp prefix. 
# Deletes 30+ days old backups
# Run with cron,
#
####################################################

filename=$(basename $1)
path=$(dirname $1)
dest=$2

 if [ -e "$1" ] && [ -d "$dest" ]; then
   tar -C "$path" -czvf "$dest"/$(date +%Y%m%dT%H%M%SZ)."$filename".tar.gz "$filename"
   # delete 30+ days old
   find "$2" -name "*.gz" -type f -mtime +30 -delete
 else
   echo "$1 or $dest does not exist."
   echo "usage: "
   echo "backupFileTimestamp /path/to/filename /destination/path/to/backup/"
 fi
 