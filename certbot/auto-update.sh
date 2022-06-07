#!/bin/bash

####################################################
#
# "Simple certbot Let's Encrypt auto update script"
#
####################################################

# get ISO 8601 timestamp
TIMESTAMP=$(date +"%Y%m%dT%H%M%SZ")

# open file for output / delete previous contents
echo "Starting at : $TIMESTAMP" >/var/log/certbot.log 2>&1

/usr/sbin/ufw allow 80 >>/var/log/certbot.log 2>&1
certbot renew >>/var/log/certbot.log 2>&1
/usr/sbin/ufw delete allow 80 >>/var/log/certbot.log 2>&1

TIMESTAMP=$(date +"%Y%m%dT%H%M%SZ")
echo "Ended at : $TIMESTAMP" >>/var/log/certbot.log 2>&1




