#!/bin/bash

####################################################
#
# "Simple certbot Let's Encrypt auto update script"
#
####################################################

# defaults
pre_script="/usr/bin/true"
post_script="/usr/bin/true"

# get ISO 8601 timestamp
TIMESTAMP=$(date +"%Y%m%dT%H%M%SZ")

# open file for output / delete previous contents
echo "Starting at : $TIMESTAMP" >/var/log/certbot.log 2>&1

# check if param file was supplied
if [ -n "$2" ] && [ -f "$2" ]; then
	app_props="$2"
	source "$app_props"
	echo "using pre-script  : $pre_script" >>/var/log/certbot.log 2>&1
	echo "using post-script : $post_script" >>/var/log/certbot.log 2>&1
else
	echo "props       : no argument for external file supplied" >>/var/log/certbot.log 2>&1
fi

certbot renew --pre-hook "$pre_script" --post-hook "$post_script" >>/var/log/certbot.log 2>&1

TIMESTAMP=$(date +"%Y%m%dT%H%M%SZ")
echo "Ended at : $TIMESTAMP" >>/var/log/certbot.log 2>&1




