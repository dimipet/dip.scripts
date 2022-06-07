#!/bin/bash

####################################################
#
# "Simple certbot Let's Encrypt auto update script"
#
####################################################

# don't forget to add to root's crontab the following
#12 23 * * * /path/to/dip.scripts/certbot/auto-update.sh

# get ISO 8601 timestamp
TIMESTAMP=$(date +"%Y%m%dT%H%M%SZ")

# open file for output / delete previous contents
echo "Starting at : $TIMESTAMP" >/var/log/certbot.log 2>&1

/usr/sbin/ufw allow 80 >>/var/log/certbot.log 2>&1
certbot renew >>/var/log/certbot.log 2>&1
/usr/sbin/ufw delete allow 80 >>/var/log/certbot.log 2>&1

TIMESTAMP=$(date +"%Y%m%dT%H%M%SZ")
echo "Ended at : $TIMESTAMP" >>/var/log/certbot.log 2>&1




