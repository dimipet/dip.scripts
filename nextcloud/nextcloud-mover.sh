#!/bin/bash



# -----------------------------------------------------------------------------
# DEFAULT APP SETTINGS

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

# pg_dump settings
# place the dump inside nextcloud path so you can tar it at once
src_pg_dump_path=./
src_pg_dump_filename=nextcloud-sql-plain-backup.sql
src_pg_dump_filename_sha512=nextcloud-sql-plain-backup.sql.sha512

# apache settings
# used for sudo -u user occ maintenance:mode
src_apache_user=www-data
dst_apache_user=www-data

# nextcloud source settings
src_nextcloud_path=/some/path/to/your/nextcloud/instance
src_nextcloud_backup_file=nextcloud-files-backup.tar.gz
src_nextcloud_backup_file_sha512=nextcloud-files-backup.tar.gz.sha512
# nextcloud destination settings
dst_nextcloud_path=/var/www/nextcloud

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
    # create log file
    log=$timestamp.log
    touch "$log"
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
    echo "--- exiting ... " | tee -a "$log"
    exit -1
}

# FIXME use for src and dst 
# FIXME accept host/port/user/password as parameters for 
check_postgres() {
    if command -v pg_dump &> /dev/null ; then
        echo "checks      : postgres pg_dump found" | tee -a "$log"
    else 
        echo "checks      : pg_dump could not be found - are you sure you are running postgres in this host ?" | tee -a "$log"
        exit_bad
    fi

    if lsof -Pi :"$src_db_port" -sTCP:LISTEN -t >/dev/null ; then
        echo "checks      : postgres listening on port $src_db_port" | tee -a "$log"
    else 
        echo "checks      : postgres not listening port $src_db_port" | tee -a "$log"
        exit_bad
    fi

    # FIXME add user + password here
    pg_isready -d "$src_db_name" -h "$src_db_host" -p "$src_db_port" -U "$src_db_user" | grep 'accepting connections' &> /dev/null
    if [ $? -eq 0 ]; then
        echo "checks      : postgres accepting connections" | tee -a "$log"
    else 
        echo "checks      : postgres not accepting connections" | tee -a "$log"
        exit_bad
    fi

    # FIXME add -h host here + user + password
    sudo -u "$src_db_user" psql -p "$src_db_port" -lqt | cut -d \| -f 1 | grep -qw nextcloud
    if [ $? -eq 0 ]; then
        echo "checks      : postgres database $src_db_name exists" | tee -a "$log"
    else 
        echo "checks      : postgres database $src_db_name does not exists" | tee -a "$log"
        exit_bad
    fi

}

check_nextcloud() {
    if [ -d "$src_nextcloud_path" ]; then
        echo "checks      : nextcloud $src_nextcloud_path exists" | tee -a "$log"
    else
        echo "checks      : nextcloud $src_nextcloud_path does not exists" | tee -a "$log"
        exit_bad
    fi

    sudo -u "$src_apache_user" php "$src_nextcloud_path"/occ status | grep 'installed: true'&> /dev/null
    if [ $? -eq 0 ]; then
        echo "checks      : nextcloud $src_nextcloud_path/occ exists" | tee -a "$log"
    else 
        echo "checks      : nextcloud $src_nextcloud_path/occ does not exist" | tee -a "$log"
        exit_bad
    fi

    sudo -u "$src_apache_user" php "$src_nextcloud_path"/occ maintenance:mode | grep -E 'enabled|disabled'&> /dev/null
    if [ $? -eq 0 ]; then
        echo "checks      : nextcloud $(sudo -u "$src_apache_user" php "$src_nextcloud_path"/occ maintenance:mode)" | tee -a "$log"
    else 
        echo "checks      : nextcloud maintenance:mode problem" | tee -a "$log"
        exit_bad
    fi
}

check_ftp() {
    if command -v lftp &> /dev/null ; then
        echo "checks      : ftp lftp found" | tee -a "$log"
    else
        echo "checks      : ftp lftp could not be found - please install it" | tee -a "$log"
        exit_bad
    fi

    timeout 3 bash -c "cat < /dev/null > /dev/tcp/$ftp_host/$ftp_port"
    if [ $? -eq 0 ]; then
        echo "checks      : ftp remote host $ftp_host is accepting requests on port $ftp_port" | tee -a "$log"
    else 
        echo "checks      : ftp remote host $ftp_host is not accepting requests on port $ftp_port" | tee -a "$log"
        exit_bad
    fi

    ftp_list &> /dev/null
    if [ $? -eq 0 ]; then
        echo "checks      : ftp can connect to remote host $ftp_host on port $ftp_port" | tee -a "$log"
    else 
        echo "checks      : ftp cannot connect to remote host $ftp_host on port $ftp_port" | tee -a "$log"
        exit_bad
    fi

}


backup() {
    create_log
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

    # check settings sanity
    echo "checks      : starting to check settings sanity" | tee -a "$log"
    check_postgres
    check_nextcloud
    check_ftp    
    echo '-------------------------------------------------------------------------' | tee -a "$log"

    total_time=0

    # get running dir
    running_dir="$(pwd)"
    # get script dir
    script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" &>/dev/null && pwd)"

    echo "running dir : $running_dir" | tee -a "$log"
    echo "script dir  : $script_dir" | tee -a "$log"

    local_start="$(date +%s)"
    echo '-------------------------------------------------------------------------' | tee -a "$log"
    
    # set maintenance:mode
    echo "exec: occ maintenance:mode --on" | tee -a "$log"
    sudo -u www-data php "$src_nextcloud_path"/occ maintenance:mode --on 2>&1 | tee -a "$log"
    local_end="$(date +%s)"
    local_exec_time="$((local_end - local_start))"
    total_time="$((total_time + local_exec_time))"
    echo "execution time: $local_exec_time seconds" | tee -a "$log"
    echo '-------------------------------------------------------------------------' | tee -a "$log"

    # dump db
    local_start="$(date +%s)"
    echo "exec: postgres pg_dump" | tee -a "$log"
    echo "exec: pg_dump sql output is redirected to $timestamp.$src_pg_dump_filename" | tee -a "$log"
    echo "exec: pg_dump error output is redirected to $log" | tee -a "$log"
    sudo -u $src_db_user pg_dump --port="$src_db_port" --dbname="$src_db_name" > "$timestamp"."$src_pg_dump_filename" 2>> "$log"
    # FIXME use tee
    # sudo -u $src_db_user pg_dump --port="$src_db_port" --dbname="$src_db_name" 2>&1 | tee -a "$timestamp"."$src_pg_dump_filename" > /dev/null
    # sudo -u $src_db_user pg_dump --port="$src_db_port" --dbname="$src_db_name" > >(tee -a "$timestamp"."$src_pg_dump_filename") 2> >(tee -a "$log" >&2)
    echo "exec: sha512 hashing to" "$timestamp"."$src_pg_dump_filename_sha512" | tee -a "$log"
    sha512sum "$timestamp"."$src_pg_dump_filename" | tee "$timestamp"."$src_pg_dump_filename_sha512" > /dev/null
    echo "exec: uploading ..." | tee -a "$log"
    ftp_upload "$timestamp"."$src_pg_dump_filename"
    ftp_upload "$timestamp"."$src_pg_dump_filename_sha512"
    local_end="$(date +%s)"
    local_exec_time="$((local_end - local_start))"
    total_time="$((total_time + local_exec_time))"
    echo "execution time: $local_exec_time seconds" | tee -a "$log"
    echo '-------------------------------------------------------------------------' | tee -a "$log"

    # dump nextcloud + user files
    local_start="$(date +%s)"
    echo "exec: tar -czvf nextcloud files + sha512 hashing" 2>&1 | tee -a "$log"
    tar -czvf "$timestamp"."$src_nextcloud_backup_file" "$src_nextcloud_path" 2>&1 | tee -a "$log"
    sha512sum "$timestamp"."$src_nextcloud_backup_file" | tee "$timestamp"."$src_nextcloud_backup_file_sha512"
    ftp_upload "$timestamp"."$src_nextcloud_backup_file"
    ftp_upload "$timestamp"."$src_nextcloud_backup_file_sha512"
    local_end="$(date +%s)"
    local_exec_time="$((local_end - local_start))"
    total_time="$((total_time + local_exec_time))"
    echo "execution time: $local_exec_time seconds" | tee -a "$log"
    echo '-------------------------------------------------------------------------' | tee -a "$log"

    # set occ maintenance:mode
    local_start="$(date +%s)"
    echo "exec: occ maintenance:mode --off" | tee -a "$log"
    sudo -u www-data php "$src_nextcloud_path"/occ maintenance:mode --off 2>&1 | tee -a "$log"
    local_end="$(date +%s)"
    local_exec_time="$((local_end - local_start))"
    total_time="$((total_time + local_exec_time))"
    echo "execution time: $local_exec_time seconds" | tee -a "$log"
    echo '-------------------------------------------------------------------------' | tee -a "$log"

    echo "total execution time: $total_time seconds" | tee -a "$log"
    ftp_upload "$log"

}

# parse arguments
while getopts p:a: flag
do
    case "${flag}" in
        p) properties=${OPTARG};;
        a) action=${OPTARG};;
        *) echo_usage >&2
       exit 1 ;;
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

