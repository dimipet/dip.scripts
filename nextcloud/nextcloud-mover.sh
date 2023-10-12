#!/bin/bash

# -----------------------------------------------------------------------------
# DEFAULT APP SETTINGS

# postgres server settings
src_pg_user=postgres
dst_pg_user=postgres

# postgres source DB settings
src_db_host=localhost
src_db_port=5432
src_db_name=nextcloud
src_db_user=postgres
src_db_password=
# postgres destination DB settings
dst_db_host=localhost
dst_db_port=5432
dst_db_name=nextcloud
dst_db_user=postgres
dst_db_password=

# source system directory where the backup() function will use to output/place
# the postges database dumb, nextcloud files, logs etc
src_work_dir=./
# destination system directory where the restore() function will download files 
# from the ftp and then restore the postgres database dumb, nextcloud files 
# create restore process logs etc
dst_work_dir=./

# pg_dump settings
# place the dump inside nextcloud path so you can tar it at once
src_pg_dump_filename=nextcloud-sql-plain-backup.sql
src_pg_dump_filename_sha512=nextcloud-sql-plain-backup.sql.sha512

# apache settings
# used for sudo -u user occ maintenance:mode
src_apache_user=www-data
dst_apache_user=www-data

# nextcloud source system installation and data directory
# FIXME data directory not used yet
src_nextcloud_inst_path=/some/path/to/your/www/nextcloud/installation
src_nextcloud_data_path=/some/path/to/your/nextcloud/data/directory
# nextcloud backup file
src_nextcloud_inst_file_backup=nextcloud-inst-files-backup.tar.gz
src_nextcloud_inst_file_backup_sha512=nextcloud-inst-files-backup.tar.gz.sha512
src_nextcloud_data_file_backup=nextcloud-data-files-backup.tar.gz
src_nextcloud_data_file_backup_sha512=nextcloud-data-files-backup.tar.gz.sha512

# nextcloud destination system installation and data directory
# FIXME data directory not used yet
dst_nextcloud_inst_path=/some/path/to/your/www/nextcloud/installation
dst_nextcloud_data_path=/some/path/to/your/nextcloud/data/directory

# lftp settings
ftp_protocol="ftps"
ftp_host="192.168.1.2"
ftp_port="990"
ftp_user="change-this-to-your-username"
ftp_password="change-this-to-your-password"
ftp_remote_dir="/"

# DEFAULT APP SETTINGS END HERE
# -----------------------------------------------------------------------------

# get ISO 8601 timestamp
timestamp=$(date +"%Y%m%dT%H%M%SZ")

create_log() {
    local l_workdir=$1
    # create log file
    log="$timestamp".log
    touch "$l_workdir"/"$log"
}

echo_banner() {
    echo '----------------------------------------' | tee "$log"
    echo 'nextcloud mover' | tee "$log"
    echo '' | tee "$log"
    echo 'move nextcloud files and postgres db to new host' | tee "$log"
    echo '----------------------------------------' | tee "$log"
}

echo_usage() {
    echo_banner
    echo "Usage: $0 [-p] [-a]"
    echo ""
    echo "where:"
    echo "     -p: /path/to/your/properties/file"
    echo "     -a: action, choose between backup and restore"
    echo ""
    echo "WARNING: restore is destructive, will drop database and rm -rf all"
    echo "your files. Make sure you understand the script before running."
    echo ""
    echo "WARNING: backup will put nextcloud in maintenance mode and all users"
    echo "will loose access while it is running. Execution time of backup depe-"
    echo "nds on how big your database is, how many nextcloud files are being"
    echo "hosted, and how fast will these get tranfered to ftp server."
    echo ""
}

ftp_upload() {
    local l_ftp_protocol=$1
    local l_ftp_host=$2
    local l_ftp_port=$3
    local l_ftp_user=$4
    local l_ftp_password=$5
    local l_ftp_remote_dir=$6
    local l_ftp_file=$7

    lftp -c open -e "\
	set ftps:initial-prot; \
	set ftp:ssl-force true; \
	set ftp:ssl-protect-data true; \
	set ssl:verify-certificate false; \
	put -O $l_ftp_remote_dir $l_ftp_file; \
   " \
        -u "$l_ftp_user","$l_ftp_password" "$l_ftp_protocol"://"$l_ftp_host":"$l_ftp_port"
}

ftp_list() {
    local l_ftp_protocol=$1
    local l_ftp_host=$2
    local l_ftp_port=$3
    local l_ftp_user=$4
    local l_ftp_password=$5
    local l_ftp_remote_dir=$6

    lftp -c open -e "\
	set ftps:initial-prot; \
	set ftp:ssl-force true; \
	set ftp:ssl-protect-data true; \
	set ssl:verify-certificate false; \
	ls -la $l_ftp_remote_dir; \
   " \
        -u "$l_ftp_user","$l_ftp_password" "$l_ftp_protocol"://"$l_ftp_host":"$l_ftp_port"
}

exit_bad() {
    echo "--- exiting ... " | tee -a "$log"
    exit -1
}

check_postgres() {
    local l_pg_user=$1
    local l_db_host=$2
    local l_db_port=$3
    local l_db_name=$4
    local l_db_user=$5
    local l_db_password=$6

    if command -v pg_dump &>/dev/null; then
        echo "checks      : postgres pg_dump found" | tee -a "$log"
    else
        echo "checks      : pg_dump could not be found - are you sure you are running postgres in this host ?" | tee -a "$log"
        exit_bad
    fi

    if lsof -Pi :"$l_db_port" -sTCP:LISTEN -t >/dev/null; then
        echo "checks      : postgres listening on port $l_db_port" | tee -a "$log"
    else
        echo "checks      : postgres not listening port $l_db_port" | tee -a "$log"
        exit_bad
    fi

    # make sure specific ip/host and specific port is accepting connections
    pg_isready -h "$l_db_host" -p "$l_db_port" | grep 'accepting connections' &>/dev/null
    if [ $? -eq 0 ]; then
        echo "checks      : postgres accepting connections" | tee -a "$log"
    else
        echo "checks      : postgres not accepting connections" | tee -a "$log"
        exit_bad
    fi

    # make sure that the specific database user can connect to specific host:port/database
    psql postgresql://"$l_db_user":"$l_db_password"@"$l_db_host":"$l_db_port"/"$l_db_name" -lqt | cut -d \| -f 1 | grep -qw "$l_db_name"
    if [ $? -eq 0 ]; then
        echo "checks      : postgres database $l_db_user exists" | tee -a "$log"
        echo "checks      : postgres database $l_db_user can connect to $l_db_host:$l_db_port/$l_db_name" | tee -a "$log"
        echo "checks      : postgres database $l_db_name exists" | tee -a "$log"
    else
        echo "checks      : postgres something of the following went wrong :" | tee -a "$log"
        echo "checks      : postgres database $l_db_user does not exist OR ..." | tee -a "$log"
        echo "checks      : postgres database $l_db_user can not connect to $l_db_host:$l_db_port OR ..." | tee -a "$log"
        echo "checks      : postgres database $l_db_name does not exist" | tee -a "$log"
        exit_bad
    fi
}

check_nextcloud() {
    local l_apache_user=$1
    local l_nextcloud_inst_path=$2
    local l_nextcloud_data_path=$3

    if [ -d "$l_nextcloud_inst_path" ]; then
        echo "checks      : nextcloud installation $l_nextcloud_inst_path exists" | tee -a "$log"
    else
        echo "checks      : nextcloud installation $l_nextcloud_inst_path does not exist" | tee -a "$log"
        exit_bad
    fi
    
    if [ -d "$l_nextcloud_inst_path" ]; then
        echo "checks      : nextcloud data $l_nextcloud_data_path exists" | tee -a "$log"
    else
        echo "checks      : nextcloud data $l_nextcloud_data_path does not exist" | tee -a "$log"
        exit_bad
    fi

    sudo -u "$l_apache_user" php "$l_nextcloud_inst_path"/occ status | grep 'installed: true' &>/dev/null
    if [ $? -eq 0 ]; then
        echo "checks      : nextcloud $l_nextcloud_inst_path/occ exists" | tee -a "$log"
    else
        echo "checks      : nextcloud $l_nextcloud_inst_path/occ does not exist" | tee -a "$log"
        exit_bad
    fi

    sudo -u "$l_apache_user" php "$l_nextcloud_inst_path"/occ maintenance:mode | grep -E 'enabled|disabled' &>/dev/null
    if [ $? -eq 0 ]; then
        echo "checks      : nextcloud $(sudo -u "$l_apache_user" php "$l_nextcloud_inst_path"/occ maintenance:mode)" | tee -a "$log"
    else
        echo "checks      : nextcloud maintenance:mode problem" | tee -a "$log"
        exit_bad
    fi
}

check_ftp() {
    local l_ftp_protocol=$1
    local l_ftp_host=$2
    local l_ftp_port=$3
    local l_ftp_user=$4
    local l_ftp_password=$5
    local l_ftp_remote_dir=$6

    if command -v lftp &>/dev/null; then
        echo "checks      : ftp lftp found" | tee -a "$log"
    else
        echo "checks      : ftp lftp could not be found - please install it" | tee -a "$log"
        exit_bad
    fi

    timeout 3 bash -c "cat < /dev/null > /dev/tcp/$l_ftp_host/$l_ftp_port"
    if [ $? -eq 0 ]; then
        echo "checks      : ftp remote host $l_ftp_host is accepting requests on port $l_ftp_port" | tee -a "$log"
    else
        echo "checks      : ftp remote host $l_ftp_host is not accepting requests on port $l_ftp_port" | tee -a "$log"
        exit_bad
    fi

    ftp_list "$l_ftp_protocol" "$l_ftp_host" "$l_ftp_port" "$l_ftp_user" "$l_ftp_password" "$l_ftp_remote_dir" &>/dev/null
    if [ $? -eq 0 ]; then
        echo "checks      : ftp can connect to remote host $ftp_host on port $ftp_port" | tee -a "$log"
    else
        echo "checks      : ftp cannot connect to remote host $ftp_host on port $ftp_port" | tee -a "$log"
        exit_bad
    fi
}

backup() {
    create_log $src_work_dir
    echo_banner
    echo "$timestamp" | tee -a "$log"
    uname -ar | tee -a "$log"
    echo '-------------------------------------------------------------------------' | tee -a "$log"

    # application properties check if arg exist
    if [ -z "$1" ]; then
        echo "props       : no argument for external file supplied" | tee -a "$log"
        echo "props       : using DEFAULT APP SETTINGS from this script" | tee -a "$log"
    else
        app_props=$1
        echo "props file  : $app_props" | tee -a "$log"
        # check if file supplied as cli argument, exists
        if [ -f "$app_props" ]; then
            echo 'props file  : found, sourcing ...' | tee -a "$log"
            source "$app_props"
        else
            echo "props file  : $app_props does not exist." | tee -a "$log"
            exit_bad
        fi
    fi
    echo '-------------------------------------------------------------------------' | tee -a "$log"

    total_time=0

    # check settings sanity
    local_start="$(date +%s)"
    echo "checks      : starting to check settings sanity" | tee -a "$log"
    check_postgres "$src_pg_user" "$src_db_host" "$src_db_port" "$src_db_name" "$src_db_user" "$src_db_password"
    check_nextcloud "$src_apache_user" "$src_nextcloud_inst_path" "$src_nextcloud_data_path"
    check_ftp "$ftp_protocol" "$ftp_host" "$ftp_port" "$ftp_user" "$ftp_password" "$ftp_remote_dir"
    local_end="$(date +%s)"
    local_exec_time="$((local_end - local_start))"
    total_time="$((total_time + local_exec_time))"
    echo "execution time: $local_exec_time seconds" | tee -a "$log"
    echo '-------------------------------------------------------------------------' | tee -a "$log"

    
    # get running, script and working directories
    local_start="$(date +%s)"
    running_dir="$(pwd)"
    script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" &>/dev/null && pwd)"
    echo "running dir : $running_dir" | tee -a "$log"
    echo "working dir : $src_work_dir" | tee -a "$log"
    echo "script dir  : $script_dir" | tee -a "$log"
    local_end="$(date +%s)"
    local_exec_time="$((local_end - local_start))"
    total_time="$((total_time + local_exec_time))"
    echo "execution time: $local_exec_time seconds" | tee -a "$log"
    echo '-------------------------------------------------------------------------' | tee -a "$log"

    # set maintenance:mode
    local_start="$(date +%s)"
    echo "exec: occ maintenance:mode --on" | tee -a "$log"
    sudo -u www-data php "$src_nextcloud_inst_path"/occ maintenance:mode --on 2>&1 | tee -a "$log"
    local_end="$(date +%s)"
    local_exec_time="$((local_end - local_start))"
    total_time="$((total_time + local_exec_time))"
    echo "execution time: $local_exec_time seconds" | tee -a "$log"
    echo '-------------------------------------------------------------------------' | tee -a "$log"

    # dump db
    local_start="$(date +%s)"
    echo "exec: postgres pg_dump $src_work_dir" | tee -a "$log"
    echo "exec: using workdir $src_work_dir" | tee -a "$log"
    echo "exec: pg_dump sql output is redirected to $timestamp.$src_pg_dump_filename" | tee -a "$log"
    echo "exec: pg_dump error output is redirected to $log" | tee -a "$log"
    # using connection strings https://www.postgresql.org/docs/current/libpq-connect.html#LIBPQ-CONNSTRING
    pg_dump postgresql://"$src_db_user":"$src_db_password"@"$src_db_host":"$src_db_port"/"$src_db_name" > \
        >(tee "$src_work_dir"/"$timestamp"."$src_pg_dump_filename" >/dev/null) \
        2> >(tee -a "$log" >&2)
    # hash db dumb
    echo "exec: sha512 hashing to $timestamp"."$src_pg_dump_filename_sha512" | tee -a "$log"
    sha512sum "$src_work_dir"/"$timestamp"."$src_pg_dump_filename" \
        | tee "$src_work_dir"/"$timestamp"."$src_pg_dump_filename_sha512" >/dev/null
    local_end="$(date +%s)"
    local_exec_time="$((local_end - local_start))"
    total_time="$((total_time + local_exec_time))"
    echo "execution time: $local_exec_time seconds" | tee -a "$log"
    echo '-------------------------------------------------------------------------' | tee -a "$log"

    # backup nextcloud installation files
    local_start="$(date +%s)"
    echo "exec: tar nextcloud installation files" 2>&1 | tee -a "$log"
    echo "exec: using workdir $src_work_dir" | tee -a "$log"
    tar -c --exclude="$src_nextcloud_data_path" \
        -vpzf "$src_work_dir"/"$timestamp"."$src_nextcloud_inst_file_backup" \
        "$src_nextcloud_inst_path" 2>&1 | tee -a "$log"
    echo "exec: sha512 hash tar.gz" 2>&1 | tee -a "$log"        
    sha512sum "$src_work_dir"/"$timestamp"."$src_nextcloud_inst_file_backup" \
        | tee "$src_work_dir"/"$timestamp"."$src_nextcloud_inst_file_backup_sha512"
    local_end="$(date +%s)"
    local_exec_time="$((local_end - local_start))"
    total_time="$((total_time + local_exec_time))"
    echo "execution time: $local_exec_time seconds" | tee -a "$log"
    echo '-------------------------------------------------------------------------' | tee -a "$log"

    # backup nextcloud data files
        local_start="$(date +%s)"
    echo "exec: tar nextcloud data files" 2>&1 | tee -a "$log"
    echo "exec: using workdir $src_work_dir" | tee -a "$log"
    tar -cvpzf "$src_work_dir"/"$timestamp"."$src_nextcloud_data_file_backup" \
        "$src_nextcloud_data_path" 2>&1 | tee -a "$log"
    echo "exec: sha512 hash tar.gz" 2>&1 | tee -a "$log"        
    sha512sum "$src_work_dir"/"$timestamp"."$src_nextcloud_data_file_backup" \
        | tee "$src_work_dir"/"$timestamp"."$src_nextcloud_data_file_backup_sha512"
    local_end="$(date +%s)"
    local_exec_time="$((local_end - local_start))"
    total_time="$((total_time + local_exec_time))"
    echo "execution time: $local_exec_time seconds" | tee -a "$log"
    echo '-------------------------------------------------------------------------' | tee -a "$log"

    # set occ maintenance:mode
    local_start="$(date +%s)"
    echo "exec: occ maintenance:mode --off" | tee -a "$log"
    sudo -u www-data php "$src_nextcloud_inst_path"/occ maintenance:mode --off 2>&1 | tee -a "$log"
    local_end="$(date +%s)"
    local_exec_time="$((local_end - local_start))"
    total_time="$((total_time + local_exec_time))"
    echo "execution time: $local_exec_time seconds" | tee -a "$log"
    echo '-------------------------------------------------------------------------' | tee -a "$log"

    # upload files
    local_start="$(date +%s)"
    echo "exec: uploading files ..." | tee -a "$log"
    
    echo "exec: uploading $timestamp.$src_pg_dump_filename" | tee -a "$log"
    ftp_upload "$ftp_protocol" "$ftp_host" "$ftp_port" "$ftp_user" "$ftp_password" "$ftp_remote_dir" "$src_work_dir"/"$timestamp"."$src_pg_dump_filename"
    echo "exec: uploading $timestamp.$src_pg_dump_filename_sha512" | tee -a "$log"
    ftp_upload "$ftp_protocol" "$ftp_host" "$ftp_port" "$ftp_user" "$ftp_password" "$ftp_remote_dir" "$src_work_dir"/"$timestamp"."$src_pg_dump_filename_sha512"
    echo "exec: uploading $timestamp.$src_nextcloud_inst_file_backup" | tee -a "$log"
    ftp_upload "$ftp_protocol" "$ftp_host" "$ftp_port" "$ftp_user" "$ftp_password" "$ftp_remote_dir" "$src_work_dir"/"$timestamp"."$src_nextcloud_inst_file_backup"
    echo "exec: uploading $timestamp.$src_nextcloud_inst_file_backup_sha512" | tee -a "$log"
    ftp_upload "$ftp_protocol" "$ftp_host" "$ftp_port" "$ftp_user" "$ftp_password" "$ftp_remote_dir" "$src_work_dir"/"$timestamp"."$src_nextcloud_inst_file_backup_sha512"
    echo "exec: uploading $timestamp.$src_nextcloud_data_file_backup" | tee -a "$log"
    ftp_upload "$ftp_protocol" "$ftp_host" "$ftp_port" "$ftp_user" "$ftp_password" "$ftp_remote_dir" "$src_work_dir"/"$timestamp"."$src_nextcloud_data_file_backup"
    echo "exec: uploading $timestamp"."$src_nextcloud_data_file_backup_sha512" | tee -a "$log"
    ftp_upload "$ftp_protocol" "$ftp_host" "$ftp_port" "$ftp_user" "$ftp_password" "$ftp_remote_dir" "$src_work_dir"/"$timestamp"."$src_nextcloud_data_file_backup_sha512"
    local_end="$(date +%s)"
    local_exec_time="$((local_end - local_start))"
    total_time="$((total_time + local_exec_time))"
    echo "execution time: $local_exec_time seconds" | tee -a "$log"
    echo '-------------------------------------------------------------------------' | tee -a "$log"

    # upload log
    echo "total execution time: $total_time seconds" | tee -a "$log"
    echo "exec: uploading log ..." | tee -a "$log"
    echo "exec: uploading $log" | tee -a "$log"
    ftp_upload "$ftp_protocol" "$ftp_host" "$ftp_port" "$ftp_user" "$ftp_password" "$ftp_remote_dir" "$log"

}

# parse arguments
while getopts p:a: flag; do
    case "${flag}" in
    p) properties=${OPTARG} ;;
    a) action=${OPTARG} ;;
    *)
        echo_usage >&2
        exit 1
        ;;
    esac
done

# decide what to do
if [ "$action" = "backup" ]; then
    backup "$properties"
elif [ "$action" = "restore" ]; then
    restore "$properties"
else
    echo_usage
fi
