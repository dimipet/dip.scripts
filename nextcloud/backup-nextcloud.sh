#!/bin/bash

# -----------------------------------------------------------------------------
# DEFAULT APP SETTINGS

# postgres DB settings
# useful for side-by-side postgres installations (10, 12, 13 etc) 
# set the port that your instance is listening to
db_port=5432
# set database to dump
db_name=nextcloud

# pg_dump settings
# place the dump inside nextcloud path so you can tar it at once
pg_dump_path=./
pg_dump_filename=nextcloud-sql-plain-backup.sql
pg_dump_filename_sha512=nextcloud-sql-plain-backup.sql.sha512

# nextcloud settings
nextcloud_path=/some/path/to/your/nextcloud/instance
nextcloud_backup_file=nextcloud-files-backup.tar.gz
nextcloud_backup_file_sha512=nextcloud-files-backup.tar.gz.sha512

# lftp settings
ftp_protocol="ftps"
ftp_host="192.168.1.2"
ftp_port="990"
ftp_user="change-this-to-your-username"
ftp_password="change-this-to-your-password"
ftp_remote_dir="/"

# SETTINGS 
# -----------------------------------------------------------------------------

ftp_upload() {
    lftp -c open -e "\
	set ftps:initial-prot; \
	set ftp:ssl-force true; \
	set ftp:ssl-protect-data true; \
	set ssl:verify-certificate false; \
	put -O $ftp_remote_dir $1; \
   " \
        -u "$ftp_user","$ftp_password" "$ftp_protocol"://"$ftp_host":"$ftp_port"
}

ftp_list() {
    lftp -c open -e "\
	set ftps:initial-prot; \
	set ftp:ssl-force true; \
	set ftp:ssl-protect-data true; \
	set ssl:verify-certificate false; \
	ls -la $ftp_remote_dir; \
   " \
        -u "$ftp_user","$ftp_password" "$ftp_protocol"://"$ftp_host":"$ftp_port"
}

exit_bad() {
    echo "--- exiting ... " | tee -a "$backup_log"
    exit -1
}

# get ISO 8601 timestamp
timestamp=$(date +"%Y%m%dT%H%M%SZ")

# create log file
backup_log=$timestamp.log
touch "$backup_log"
echo 'nextcloud - postgres simple db + files backup' | tee "$backup_log"
echo "$timestamp" | tee -a "$backup_log"
uname -ar | tee -a "$backup_log"
echo '-------------------------------------------------------------------------' | tee -a "$backup_log"

# application properties check if arg exist 
if [ -z "$1" ]; then
    echo "props       : no argument for external file supplied" | tee -a "$backup_log"
    echo "props       : using DEFAULT APP SETTINGS from this script" | tee -a "$backup_log"    
else
    app_props=$1
    echo "props file  : $app_props" | tee -a "$backup_log"
    # check if file supplied as cli argument, exists
    if [ -f "$app_props" ]; then
        echo 'props file  : found, sourcing ...' | tee -a "$backup_log"
        source "$app_props"
    else
        echo "props file  : $app_props does not exist." | tee -a "$backup_log"
        exit_bad
    fi
fi

echo '-------------------------------------------------------------------------' | tee -a "$backup_log"
# check settings sanity
echo "checks      : starting to check settings sanity" | tee -a "$backup_log"

if command -v pg_dump &> /dev/null ; then
    echo "checks      : postgres pg_dump found" | tee -a "$backup_log"
else 
    echo "checks      : pg_dump could not be found - are you sure you are running postgres in this host ?" | tee -a "$backup_log"
    exit_bad
fi

if lsof -Pi :"$db_port" -sTCP:LISTEN -t >/dev/null ; then
    echo "checks      : postgres listening on port $db_port" | tee -a "$backup_log"
else 
    echo "checks      : postgres not listening port $db_port" | tee -a "$backup_log"
    exit_bad
fi

pg_isready -d "$db_name" -h localhost -p "$db_port" -U "$db_user" | grep 'accepting connections' &> /dev/null
if [ $? -eq 0 ]; then
    echo "checks      : postgres accepting connections" | tee -a "$backup_log"
else 
    echo "checks      : postgres not accepting connections" | tee -a "$backup_log"
    exit_bad
fi
sudo -u postgres psql -lqt | cut -d \| -f 1 | grep -qw nextcloud
if [ $? -eq 0 ]; then
    echo "checks      : postgres database $db_name exists" | tee -a "$backup_log"
else 
    echo "checks      : postgres database $db_name does not exists" | tee -a "$backup_log"
    exit_bad
fi

if [ -d "$nextcloud_path" ]; then
    echo "checks      : nextcloud $nextcloud_path exists" | tee -a "$backup_log"
else
    echo "checks      : nextcloud $nextcloud_path does not exists" | tee -a "$backup_log"
    exit_bad
fi

sudo -u www-data php "$nextcloud_path"/occ status | grep 'installed: true'&> /dev/null
if [ $? -eq 0 ]; then
    echo "checks      : nextcloud $nextcloud_path/occ exists" | tee -a "$backup_log"
else 
    echo "checks      : nextcloud $nextcloud_path/occ does not exist" | tee -a "$backup_log"
    exit_bad
fi

sudo -u www-data php "$nextcloud_path"/occ maintenance:mode | grep -E 'enabled|disabled'&> /dev/null
if [ $? -eq 0 ]; then
    echo "checks      : nextcloud $(sudo -u www-data php "$nextcloud_path"/occ maintenance:mode)" | tee -a "$backup_log"
else 
    echo "checks      : nextcloud maintenance:mode problem" | tee -a "$backup_log"
    exit_bad
fi


if command -v lftp &> /dev/null ; then
    echo "checks      : ftp lftp found"
else
    echo "checks      : ftp lftp could not be found - please install it"
    exit_bad
fi

timeout 3 bash -c "cat < /dev/null > /dev/tcp/$ftp_host/$ftp_port"
if [ $? -eq 0 ]; then
    echo "checks      : ftp remote host $ftp_host is accepting requests on port $ftp_port" | tee -a "$backup_log"
else 
    echo "checks      : ftp remote host $ftp_host is not accepting requests on port $ftp_port" | tee -a "$backup_log"
    exit_bad
fi

ftp_list &> /dev/null
if [ $? -eq 0 ]; then
    echo "checks      : ftp can connect to remote host $ftp_host on port $ftp_port" | tee -a "$backup_log"
else 
    echo "checks      : ftp cannot connect to remote host $ftp_host on port $ftp_port" | tee -a "$backup_log"
    exit_bad
fi

echo '-------------------------------------------------------------------------' | tee -a "$backup_log"

total_time=0

# get running dir
running_dir="$(pwd)"
# get script dir
script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" &>/dev/null && pwd)"

echo "running dir : $running_dir" | tee -a "$backup_log"
echo "script dir  : $script_dir" | tee -a "$backup_log"

local_start="$(date +%s)"
echo '-------------------------------------------------------------------------' | tee -a "$backup_log"
echo "exec: occ maintenance:mode --on" | tee -a "$backup_log"
sudo -u www-data php "$nextcloud_path"/occ maintenance:mode --on 2>&1 | tee -a "$backup_log"
local_end="$(date +%s)"
local_exec_time="$((local_end - local_start))"
total_time="$((total_time + local_exec_time))"
echo "execution time: $local_exec_time seconds" | tee -a "$backup_log"

local_start="$(date +%s)"
echo '-------------------------------------------------------------------------' | tee -a "$backup_log"
echo "exec: postgres pg_dump" | tee -a "$backup_log"
echo "exec: pg_dump sql output is redirected to $timestamp.$pg_dump_filename" | tee -a "$backup_log"
echo "exec: pg_dump error output is redirected to $backup_log" | tee -a "$backup_log"
sudo -u postgres pg_dump --port="$db_port" --dbname="$db_name" > "$timestamp"."$pg_dump_filename" 2>> "$backup_log"
# FIXME use tee
# sudo -u postgres pg_dump --port="$db_port" --dbname="$db_name" 2>&1 | tee -a "$timestamp"."$pg_dump_filename" > /dev/null
# sudo -u postgres pg_dump --port="$db_port" --dbname="$db_name" > >(tee -a "$timestamp"."$pg_dump_filename") 2> >(tee -a "$backup_log" >&2)
echo "exec: sha512 hashing to" "$timestamp"."$pg_dump_filename_sha512" | tee -a "$backup_log"
sha512sum "$timestamp"."$pg_dump_filename" | tee "$timestamp"."$pg_dump_filename_sha512" > /dev/null
echo "exec: uploading ..." | tee -a "$backup_log"
ftp_upload "$timestamp"."$pg_dump_filename"
ftp_upload "$timestamp"."$pg_dump_filename_sha512"
local_end="$(date +%s)"
local_exec_time="$((local_end - local_start))"
total_time="$((total_time + local_exec_time))"
echo "execution time: $local_exec_time seconds" | tee -a "$backup_log"

local_start="$(date +%s)"
echo '-------------------------------------------------------------------------' | tee -a "$backup_log"
echo "exec: tar -czvf nextcloud files + sha512 hashing" 2>&1 | tee -a "$backup_log"
tar -czvf "$timestamp"."$nextcloud_backup_file" "$nextcloud_path" 2>&1 | tee -a "$backup_log"
sha512sum "$timestamp"."$nextcloud_backup_file" | tee "$timestamp"."$nextcloud_backup_file_sha512"
ftp_upload "$timestamp"."$nextcloud_backup_file"
ftp_upload "$timestamp"."$nextcloud_backup_file_sha512"
local_end="$(date +%s)"
local_exec_time="$((local_end - local_start))"
total_time="$((total_time + local_exec_time))"
echo "execution time: $local_exec_time seconds" | tee -a "$backup_log"

local_start="$(date +%s)"
echo '-------------------------------------------------------------------------' | tee -a "$backup_log"
echo "exec: occ maintenance:mode --off" | tee -a "$backup_log"
sudo -u www-data php "$nextcloud_path"/occ maintenance:mode --off 2>&1 | tee -a "$backup_log"
local_end="$(date +%s)"
local_exec_time="$((local_end - local_start))"
total_time="$((total_time + local_exec_time))"
echo "execution time: $local_exec_time seconds" | tee -a "$backup_log"

echo '-------------------------------------------------------------------------' | tee -a "$backup_log"
echo "total execution time: $total_time seconds" | tee -a "$backup_log"
ftp_upload "$backup_log"

