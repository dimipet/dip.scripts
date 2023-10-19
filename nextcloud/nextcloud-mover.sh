#!/bin/bash

# -----------------------------------------------------------------------------
# DEFAULT APP GLOBAL SETTINGS

# app artifacts filename suffixes
backup_log_suffix="backup.log"
restore_log_suffix="restore.log"
# sha512 checksums of files produced
sha512_filename_suffix="hash.sha512"
# backup db and restore from files using this suffix 
pg_dump_filename_suffix="nextcloud-sql-plain-backup.sql"
# nextcloud backup files suffix: seperate for install and data
nextcloud_inst_filename_suffix="nextcloud-inst-files-backup.tar.gz"
nextcloud_data_filename_suffix="nextcloud-data-files-backup.tar.gz"
# source system directory where the backup() function will produce backups, logs, shas
src_work_dir="./"
# destination system directory where the backup() function will produce backups, logs, shas
dst_work_dir="./"

# -----------------------------------------------------------------------------
# USER APP GLOBAL SETTINGS

# postgres server settings
src_pg_user="postgres"
dst_pg_user="postgres"

# postgres source DB settings
src_db_host="localhost"
src_db_port="5432"
src_db_name="nextcloud"
src_db_user="postgres"
src_db_password=""
# postgres destination DB settings
dst_db_host="localhost"
dst_db_port="5432"
dst_db_name="nextcloud"
dst_db_user="postgres"
dst_db_password=""

# apache settings
# used for sudo -u user occ maintenance:mode
src_apache_user="www-data"
dst_apache_user="www-data"

# nextcloud source system installation and data directory
# FIXME data directory not used yet
src_nextcloud_inst_path="/some/path/to/your/www/nextcloud/installation"
src_nextcloud_data_path="/some/path/to/your/nextcloud/data/directory"

# nextcloud destination system installation directory
dst_nextcloud_inst_path="/some/path/to/your/www/nextcloud/installation"
# CAUTION: DATA LOSS
# handle nextcloud installation path on destination, with the following options
#   skip     : do nothing, no loss
#   create   : mkdir if it does not exist otherwise rm -rf && mkdir
#   overwite : in any case untar in path specified
dst_nextcloud_inst_path_handle="skip"
# nextcloud destination system data directory
dst_nextcloud_data_path="/some/path/to/your/nextcloud/data/directory"
# CAUTION: DATA LOSS
# same as above but for data files
dst_nextcloud_data_path_handle="skip"

# lftp settings
ftp_protocol="ftps"
ftp_host="192.168.1.2"
ftp_port="990"
ftp_user="change-this-to-your-username"
ftp_password="change-this-to-your-password"
ftp_remote_dir="some-dir/"
# ftp server will usually have many backups uploaded from source host,
# execute a listing (such as ls -la) on ftp server and pick the 1st
# file that shows up in order to download and restore. 
# Possible sorting options are: "name", "size", "date" and their 
# meaning are as follows
#   name : will sort backups alphabetical, 
#   size : will sort backups from max to min size 
#   date : will sort backups from newest to oldest 
# Specifying a specific filename is not supported yet.
# Listing (ls -la) is case-sensitive
ftp_sorting_prefer="date"


# DEFAULT APP SETTINGS END HERE
# -----------------------------------------------------------------------------

echo_banner() {
    echo '----------------------------------------'
    echo 'nextcloud-mover'
    echo ''
    echo 'move nextcloud files and postgres db to new host'
    echo '----------------------------------------'
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
    local l_ftp_protocol="$1"
    local l_ftp_host="$2"
    local l_ftp_port="$3"
    local l_ftp_user="$4"
    local l_ftp_password="$5"
    local l_ftp_remote_dir="$6"
    local l_ftp_file="$7"

    lftp -c open -e "\
	set ftps:initial-prot; \
	set ftp:ssl-force true; \
	set ftp:ssl-protect-data true; \
	set ssl:verify-certificate false; \
    set net:timeout 5; \
    set net:max-retries 2; \
    set net:reconnect-interval-base 5; \
    set xfer:verify true; \
	put -O $l_ftp_remote_dir $l_ftp_file; \
    " \
        -u "$l_ftp_user","$l_ftp_password" "$l_ftp_protocol"://"$l_ftp_host":"$l_ftp_port"
}

ftp_find() {
    local l_ftp_protocol="$1"
    local l_ftp_host="$2"
    local l_ftp_port="$3"
    local l_ftp_user="$4"
    local l_ftp_password="$5"
    local l_ftp_remote_dir="$6"
    local l_ftp_file="$7"
    
    lftp -c open -e "\
	    set ftps:initial-prot; \
	    set ftp:ssl-force true; \
	    set ftp:ssl-protect-data true; \
	    set ssl:verify-certificate false; \
        cd $l_ftp_remote_dir; \
	    find $l_ftp_file; \
    " \
        -u "$l_ftp_user","$l_ftp_password" "$l_ftp_protocol"://"$l_ftp_host":"$l_ftp_port"
}

ftp_download() {
    local l_ftp_protocol="$1"
    local l_ftp_host="$2"
    local l_ftp_port="$3"
    local l_ftp_user="$4"
    local l_ftp_password="$5"
    local l_ftp_remote_dir="$6"
    local l_ftp_file="$7"
    
    lftp -u "$l_ftp_user","$l_ftp_password" "$l_ftp_host" <<EOF
        set ftps:initial-prot;
        set ftp:ssl-force true;
        set ftp:ssl-protect-data true;
        set ssl:verify-certificate false;
        set net:timeout 5;
        set net:max-retries 2;
        set net:reconnect-interval-base 5;
        set xfer:clobber on;
        cd "$l_ftp_remote_dir"
        get "$l_ftp_file"
EOF
}

ftp_list() {
    local l_ftp_protocol="$1"
    local l_ftp_host="$2"
    local l_ftp_port="$3"
    local l_ftp_user="$4"
    local l_ftp_password="$5"
    local l_ftp_remote_dir="$6"
    local l_ftp_remote_sort="$7"

    lftp -c open -e "\
	set ftps:initial-prot; \
	set ftp:ssl-force true; \
	set ftp:ssl-protect-data true; \
	set ssl:verify-certificate false; \
	cls --sort=$l_ftp_remote_sort $l_ftp_remote_dir; \
    " \
        -u "$l_ftp_user","$l_ftp_password" "$l_ftp_protocol"://"$l_ftp_host":"$l_ftp_port"
}

exit_bad() {
    echo "--- exiting ... "
    exit -1
}

check_postgres() {
    local l_log="$1"
    local l_pg_user="$2"
    local l_db_host="$3"
    local l_db_port="$4"
    local l_db_name="$5"
    local l_db_user="$6"
    local l_db_password="$7"

    if command -v pg_dump &>/dev/null; then
        echo "checks      : postgres pg_dump found" | tee -a "$l_log"
    else
        echo "checks      : pg_dump could not be found - are you sure you are running postgres in this host ?" | tee -a "$l_log"
        exit_bad
    fi

    # if lsof -Pi :"$l_db_port" -sTCP:LISTEN -t >/dev/null; then
    #     echo "checks      : postgres listening on port $l_db_port" | tee -a "$l_log"
    # else
    #     echo "checks      : postgres not listening port $l_db_port" | tee -a "$l_log"
    #     exit_bad
    # fi

    # make sure specific ip/host and specific port is accepting connections
    pg_isready -h "$l_db_host" -p "$l_db_port" | grep 'accepting connections' &>/dev/null
    if [ $? -eq 0 ]; then
        echo "checks      : postgres accepting connections" | tee -a "$l_log"
    else
        # keep the error in log file
        pg_isready -h "$l_db_host" -p "$l_db_port" > /dev/null 2> >(tee -a "$l_log")
        echo "checks      : postgres not accepting connections" | tee -a "$l_log"
        exit_bad
    fi

    # make sure that the specific database user can connect to specific host:port/database
    psql postgresql://"$l_db_user":"$l_db_password"@"$l_db_host":"$l_db_port"/"$l_db_name" -lqt | cut -d \| -f 1 | grep -qw "$l_db_name"
    if [ $? -eq 0 ]; then
        echo "checks      : postgres database $l_db_user exists" | tee -a "$l_log"
        echo "checks      : postgres database $l_db_user can connect to $l_db_host:$l_db_port/$l_db_name" | tee -a "$l_log"
        echo "checks      : postgres database $l_db_name exists" | tee -a "$l_log"
    else
        # keep the error in log file
        psql postgresql://"$l_db_user":"$l_db_password"@"$l_db_host":"$l_db_port"/"$l_db_name" -lqt > /dev/null 2> >(tee -a "$l_log")
        echo "checks      : postgres something of the following went wrong :" | tee -a "$l_log"
        echo "checks      : postgres database $l_db_user does not exist OR ..." | tee -a "$l_log"
        echo "checks      : postgres database $l_db_user can not connect to $l_db_host:$l_db_port OR ..." | tee -a "$l_log"
        echo "checks      : postgres database $l_db_name does not exist" | tee -a "$l_log"
        exit_bad
    fi
}

check_nextcloud() {
    local l_log="$1"
    local l_apache_user="$2"
    local l_nextcloud_inst_path="$3"
    local l_nextcloud_data_path="$4"
    
}

check_src_nextcloud() {
    local l_log="$1"
    local l_apache_user="$2"
    local l_nextcloud_inst_path="$3"
    local l_nextcloud_data_path="$4"

    check_nextcloud "$l_log" "$l_apache_user" "$l_nextcloud_inst_path" "$l_nextcloud_data_path"

    if [ -d "$l_nextcloud_inst_path" ]; then
        echo "checks      : nextcloud installation $l_nextcloud_inst_path exists" | tee -a "$l_log"
    else
        echo "checks      : nextcloud installation $l_nextcloud_inst_path does not exist" | tee -a "$l_log"
        exit_bad
    fi

    if [ -d "$l_nextcloud_data_path" ]; then
        echo "checks      : nextcloud data $l_nextcloud_data_path exists" | tee -a "$l_log"
    else
        echo "checks      : nextcloud data $l_nextcloud_data_path does not exist" | tee -a "$l_log"
        exit_bad
    fi

    sudo -u "$l_apache_user" php "$l_nextcloud_inst_path"/occ status | grep 'installed: true' &>/dev/null
    if [ $? -eq 0 ]; then
        echo "checks      : nextcloud $l_nextcloud_inst_path/occ exists" | tee -a "$l_log"
    else
        echo "checks      : nextcloud $l_nextcloud_inst_path/occ does not exist" | tee -a "$l_log"
        exit_bad
    fi

    sudo -u "$l_apache_user" php "$l_nextcloud_inst_path"/occ maintenance:mode | grep -E 'enabled|disabled' &>/dev/null
    if [ $? -eq 0 ]; then
        echo "checks      : nextcloud $(sudo -u "$l_apache_user" php "$l_nextcloud_inst_path"/occ maintenance:mode)" | tee -a "$l_log"
    else
        echo "checks      : nextcloud maintenance:mode problem" | tee -a "$l_log"
        exit_bad
    fi

}

check_dst_nextcloud() {
    local l_log="$1"
    local l_apache_user="$2"
    local l_nextcloud_inst_path="$3"
    local l_nextcloud_data_path="$4"

    check_nextcloud "$l_apache_user" "$l_nextcloud_inst_path" "$l_nextcloud_data_path"
    
    # check directory handle sanity
    if [ -d "$l_nextcloud_inst_path" ]; then
        echo "checks      : nextcloud installation exists in $l_nextcloud_inst_path" | tee -a "$l_log"
        case "$dst_nextcloud_inst_path_handle" in
            skip)
                echo "checks      : nextcloud-mover will not DELETE your $l_nextcloud_inst_path"
                echo "checks      : nextcloud-mover will not CREATE path $l_nextcloud_inst_path"
                echo "checks      : nextcloud-mover will not RESTORE a backup to $l_nextcloud_inst_path"
                echo "checks      : nextcloud-mover will SKIP everyting"
                ;;
            create)
                echo "checks      : nextcloud-mover CAUTION !!! for you nextcloud INSTALLATION files"
                echo "checks      : nextcloud-mover will DELETE your $l_nextcloud_inst_path"
                echo "checks      : nextcloud-mover will CREATE path $l_nextcloud_inst_path"
                echo "checks      : nextcloud-mover will RESTORE a backup to $l_nextcloud_inst_path"
                ;;
            overwrite)
                echo "checks      : nextcloud-mover CAUTION !!! for you nextcloud INSTALLATION files"
                echo "checks      : nextcloud-mover will not DELETE your $l_nextcloud_inst_path"
                echo "checks      : nextcloud-mover will not CREATE path $l_nextcloud_inst_path"
                echo "checks      : nextcloud-mover will RESTORE a backup to/and OVERWITE $l_nextcloud_inst_path"
                ;;
            *)
                echo "checks      : nextcloud-mover uknown option found: $dst_nextcloud_inst_path_handle"
                exit_bad
                ;;
        esac
    else
        echo "checks      : nextcloud installation does not exist in $l_nextcloud_inst_path" | tee -a "$l_log"
        case "$dst_nextcloud_inst_path_handle" in
            skip)
                echo "checks      : nextcloud-mover will not CREATE path $l_nextcloud_inst_path"
                echo "checks      : nextcloud-mover will not RESTORE a backup to $l_nextcloud_inst_path"
                echo "checks      : nextcloud-mover will SKIP everyting"
                ;;
            create)
                echo "checks      : nextcloud-mover will CREATE path $l_nextcloud_inst_path"
                echo "checks      : nextcloud-mover will RESTORE a backup to $l_nextcloud_inst_path"
                ;;
            overwrite)
                echo "checks      : nextcloud-mover cannot OVERWITE path $l_nextcloud_inst_path that does not exist"
                exit_bad
                ;;
            *)
                echo "checks      : nextcloud-mover uknown option found: $dst_nextcloud_inst_path_handle"
                exit_bad
                ;;
        esac
    fi

}

check_ftp() {
    local l_log="$1"
    local l_ftp_protocol="$2"
    local l_ftp_host="$3"
    local l_ftp_port="$4"
    local l_ftp_user="$5"
    local l_ftp_password="$6"
    local l_ftp_remote_dir="$7"
    local l_ftp_remote_sort="$8"

    if command -v lftp &>/dev/null; then
        echo "checks      : ftp lftp found" | tee -a "$l_log"
    else
        echo "checks      : ftp lftp could not be found - please install it" | tee -a "$l_log"
        exit_bad
    fi

    timeout 3 bash -c "cat < /dev/null > /dev/tcp/$l_ftp_host/$l_ftp_port"
    if [ $? -eq 0 ]; then
        echo "checks      : ftp remote host $l_ftp_host is accepting requests on port $l_ftp_port" | tee -a "$l_log"
    else
        echo "checks      : ftp remote host $l_ftp_host is not accepting requests on port $l_ftp_port" | tee -a "$l_log"
        exit_bad
    fi

    ftp_list "$l_ftp_protocol" "$l_ftp_host" "$l_ftp_port" "$l_ftp_user" "$l_ftp_password" "$l_ftp_remote_dir" "$l_ftp_remote_sort" &>/dev/null
    if [ $? -eq 0 ]; then
        echo "checks      : ftp can connect to remote host $ftp_host on port $ftp_port" | tee -a "$l_log"
    else
        echo "checks      : ftp cannot connect to remote host $ftp_host on port $ftp_port" | tee -a "$l_log"
        exit_bad
    fi
}

backup() {
    # get ISO 8601 timestamp
    local timestamp
    timestamp=$(date +"%Y%m%dT%H%M%SZ")
    
    # declare log filename
    local logfile
    logfile="$timestamp"."$backup_log_suffix"

    local app_props

    # application properties check arg and if file exists
    if [ -n "$1" ] && [ -f "$1" ]; then
        app_props="$1"
        source "$app_props"
        # change to working dir
        cd "$src_work_dir" || exit_bad
        touch "$logfile"
        echo "$timestamp" | tee -a "$logfile"
        uname -ar | tee -a "$logfile"
        echo "props file  : $app_props" | tee -a "$logfile"
        echo 'props file  : found & sourced' | tee -a "$logfile"
    else
        echo "props       : no argument for external file supplied" | tee -a "$logfile"
        echo "props       : using DEFAULT APP SETTINGS from this script" | tee -a "$logfile"
        cd "$src_work_dir" || exit_bad
        touch "$logfile"
    fi
    echo '-------------------------------------------------------------------------' | tee -a "$logfile"

    # create sha512 file
    local sha512file
    sha512file="$timestamp"."$sha512_filename_suffix"
    touch "$sha512file"

    # declare pg_dump filename
    local pg_dump_file
    pg_dump_file="$timestamp"."$pg_dump_filename_suffix"

    # declare nextcloud installation backup filename
    local nextcloud_inst_bu_file
    nextcloud_inst_bu_file="$timestamp"."$nextcloud_inst_filename_suffix"

    # declare nextcloud data backup file
    local nextcloud_data_bu_file
    nextcloud_data_bu_file="$timestamp"."$nextcloud_data_filename_suffix"

    # starter time counters
    local total_time
    local local_start
    local local_end
    local local_exec_time
    total_time=0
    local_start=0
    local_end=0
    local_exec_time=0

    # check settings sanity
    local_start="$(date +%s)"
    echo "checks      : starting to check settings sanity" | tee -a "$logfile"
    check_postgres "$logfile" "$src_pg_user" "$src_db_host" "$src_db_port" "$src_db_name" "$src_db_user" "$src_db_password"
    check_src_nextcloud "$logfile" "$src_apache_user" "$src_nextcloud_inst_path" "$src_nextcloud_data_path"
    check_ftp "$logfile" "$ftp_protocol" "$ftp_host" "$ftp_port" "$ftp_user" "$ftp_password" "$ftp_remote_dir" "$ftp_sorting_prefer"
    local_end="$(date +%s)"
    local_exec_time="$((local_end - local_start))"
    total_time="$((total_time + local_exec_time))"
    echo "exec time   : $local_exec_time seconds" | tee -a "$logfile"
    echo '-------------------------------------------------------------------------' | tee -a "$logfile"
    
    # get running, script and working directories and files
    local_start="$(date +%s)"
    script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" &>/dev/null && pwd)"
    echo "script dir          : $script_dir" | tee -a "$logfile"
    echo "working dir         : $src_work_dir" | tee -a "$logfile"
    echo "log file            : $logfile" | tee -a "$logfile"
    echo "sha512 file         : $sha512file" | tee -a "$logfile"
    echo "pgdump file         : $pg_dump_file" | tee -a "$logfile"
    echo "nextcloud inst file : $nextcloud_inst_bu_file" | tee -a "$logfile"
    echo "nextcloud data file : $nextcloud_data_bu_file" | tee -a "$logfile"
    local_end="$(date +%s)"
    local_exec_time="$((local_end - local_start))"
    total_time="$((total_time + local_exec_time))"
    echo "exec time   : $local_exec_time seconds" | tee -a "$logfile"
    echo '-------------------------------------------------------------------------' | tee -a "$logfile"

    # set maintenance:mode
    local_start="$(date +%s)"
    echo "exec        : occ maintenance:mode --on" | tee -a "$logfile"
    sudo -u www-data php "$src_nextcloud_inst_path"/occ maintenance:mode --on 2>&1 | tee -a "$logfile"
    local_end="$(date +%s)"
    local_exec_time="$((local_end - local_start))"
    total_time="$((total_time + local_exec_time))"
    echo "exec time   : $local_exec_time seconds" | tee -a "$logfile"
    echo '-------------------------------------------------------------------------' | tee -a "$logfile"

    # # dump db
    local_start="$(date +%s)"
    echo "exec        : postgres pg_dump" | tee -a "$logfile"
    echo "exec        : pg_dump sql output is redirected to $timestamp.$pg_dump_filename_suffix" | tee -a "$logfile"
    echo "exec        : pg_dump error output is redirected to $logfile" | tee -a "$logfile"
    # using connection strings https://www.postgresql.org/docs/current/libpq-connect.html#LIBPQ-CONNSTRING
    pg_dump postgresql://"$src_db_user":"$src_db_password"@"$src_db_host":"$src_db_port"/"$src_db_name" > \
        >(tee "$pg_dump_file" >/dev/null) \
        2> >(tee -a "$logfile" >&2)
    # hash db dumb
    echo "exec        : hashing $timestamp.$pg_dump_filename_suffix to $sha512file" | tee -a "$logfile"
    sha512sum "$pg_dump_file" | tee -a "$sha512file" >/dev/null
    local_end="$(date +%s)"
    local_exec_time="$((local_end - local_start))"
    total_time="$((total_time + local_exec_time))"
    echo "exec time   : $local_exec_time seconds" | tee -a "$logfile"
    echo '-------------------------------------------------------------------------' | tee -a "$logfile"

    # backup nextcloud installation files
    local_start="$(date +%s)"
    echo "exec        : tar nextcloud installation files" 2>&1 | tee -a "$logfile"
    tar -c --exclude="$src_nextcloud_data_path" \
        -vpzf "$nextcloud_inst_bu_file" \
        "$src_nextcloud_inst_path" 2>&1 | tee -a "$logfile"
    echo "exec        : hashing $timestamp.$nextcloud_inst_filename_suffix to sha512file" 2>&1 | tee -a "$logfile"        
    sha512sum "$nextcloud_inst_bu_file" | tee -a "$sha512file" >/dev/null
    local_end="$(date +%s)"
    local_exec_time="$((local_end - local_start))"
    total_time="$((total_time + local_exec_time))"
    echo "exec time   : $local_exec_time seconds" | tee -a "$logfile"
    echo '-------------------------------------------------------------------------' | tee -a "$logfile"

    # backup nextcloud data files
    local_start="$(date +%s)"
    echo "exec        : tar nextcloud data files" 2>&1 | tee -a "$logfile"
    tar -cvpzf "$nextcloud_data_bu_file" "$src_nextcloud_data_path" 2>&1 | tee -a "$logfile"
    echo "exec        : hashing $timestamp.$nextcloud_data_filename_suffix to sha512file" 2>&1 | tee -a "$logfile"        
    sha512sum "$nextcloud_data_bu_file" | tee -a "$sha512file" >/dev/null
    local_end="$(date +%s)"
    local_exec_time="$((local_end - local_start))"
    total_time="$((total_time + local_exec_time))"
    echo "exec time   : $local_exec_time seconds" | tee -a "$logfile"
    echo '-------------------------------------------------------------------------' | tee -a "$logfile"

    # set occ maintenance:mode
    local_start="$(date +%s)"
    echo "exec        : occ maintenance:mode --off" | tee -a "$logfile"
    sudo -u www-data php "$src_nextcloud_inst_path"/occ maintenance:mode --off 2>&1 | tee -a "$logfile"
    local_end="$(date +%s)"
    local_exec_time="$((local_end - local_start))"
    total_time="$((total_time + local_exec_time))"
    echo "exec time   : $local_exec_time seconds" | tee -a "$logfile"
    echo '-------------------------------------------------------------------------' | tee -a "$logfile"

    # upload files
    local_start="$(date +%s)"
    echo "exec        : uploading files ..." | tee -a "$logfile"
    
    echo "exec        : uploading pg_dump_file" | tee -a "$logfile"
    ftp_upload "$ftp_protocol" "$ftp_host" "$ftp_port" "$ftp_user" "$ftp_password" "$ftp_remote_dir" "$pg_dump_file"
    if [ $? -ne 0 ]; then exit_bad; fi 
    
    echo "exec        : uploading $nextcloud_inst_bu_file" | tee -a "$logfile"
    ftp_upload "$ftp_protocol" "$ftp_host" "$ftp_port" "$ftp_user" "$ftp_password" "$ftp_remote_dir" "$nextcloud_inst_bu_file"
    if [ $? -ne 0 ]; then exit_bad; fi 

    echo "exec        : uploading $nextcloud_data_bu_file" | tee -a "$logfile"
    ftp_upload "$ftp_protocol" "$ftp_host" "$ftp_port" "$ftp_user" "$ftp_password" "$ftp_remote_dir" "$nextcloud_data_bu_file"
    if [ $? -ne 0 ]; then exit_bad; fi 
    
    echo "exec        : uploading $sha512file" | tee -a "$logfile"
    ftp_upload "$ftp_protocol" "$ftp_host" "$ftp_port" "$ftp_user" "$ftp_password" "$ftp_remote_dir" "$sha512file"
    if [ $? -ne 0 ]; then exit_bad; fi 
        
    local_end="$(date +%s)"
    local_exec_time="$((local_end - local_start))"
    total_time="$((total_time + local_exec_time))"
    echo "exec time   : $local_exec_time seconds" | tee -a "$logfile"
    echo '-------------------------------------------------------------------------' | tee -a "$logfile"

    # upload log
    echo "total time  : $total_time seconds" | tee -a "$logfile"
    echo "exec        : uploading log ..." | tee -a "$logfile"
    echo "exec        : uploading $logfile" | tee -a "$logfile"
    ftp_upload "$ftp_protocol" "$ftp_host" "$ftp_port" "$ftp_user" "$ftp_password" "$ftp_remote_dir" "$logfile"

}

restore() {
    # get ISO 8601 timestamp
    local timestamp
    timestamp=$(date +"%Y%m%dT%H%M%SZ")
    
    # declare log filename
    local logfile
    logfile="$timestamp"."$restore_log_suffix"

    local app_props

    # application properties check arg and if file exists
    if [ -n "$1" -a -f "$1" ]; then
        app_props="$1"
        source "$app_props"
        # change to working dir
        cd "$dst_work_dir" || exit_bad
        touch "$logfile"
        echo "$timestamp" | tee -a "$logfile"
        uname -ar | tee -a "$logfile"
        echo "props file  : $app_props" | tee -a "$logfile"
        echo 'props file  : found & sourced' | tee -a "$logfile"
    else
        echo "props       : no argument for external file supplied" | tee -a "$logfile"
        echo "props       : using DEFAULT APP SETTINGS from this script" | tee -a "$logfile"
        cd "$src_work_dir" || exit_bad
        touch "$logfile"
    fi
    echo '-------------------------------------------------------------------------' | tee -a "$logfile"



    # find sha512 file
    local sha512file
    # sha512file="$timestamp"."$sha512_filename_suffix"
    # touch "$sha512file"

    # find pg_dump filename
    local pg_dump_file
    # pg_dump_file="$timestamp"."$pg_dump_filename_suffix"

    # find nextcloud installation backup filename
    local nextcloud_inst_bu_file
    # nextcloud_inst_bu_file="$timestamp"."$nextcloud_inst_filename_suffix"

    # find nextcloud data backup file
    local nextcloud_data_bu_file
    # nextcloud_data_bu_file="$timestamp"."$nextcloud_data_filename_suffix"

    # starter time counters
    local total_time
    local local_start
    local local_end
    local local_exec_time
    total_time=0
    local_start=0
    local_end=0
    local_exec_time=0

    # check settings sanity
    local_start="$(date +%s)"
    echo "checks      : starting to check settings sanity" | tee -a "$logfile"
    check_postgres "$logfile" "$dst_pg_user" "$dst_db_host" "$dst_db_port" "$dst_db_name" "$dst_db_user" "$dst_db_password"
    check_dst_nextcloud "$logfile" "$dst_apache_user" "$dst_nextcloud_inst_path" "$dst_nextcloud_data_path"
    check_ftp "$logfile" "$ftp_protocol" "$ftp_host" "$ftp_port" "$ftp_user" "$ftp_password" "$ftp_remote_dir" "$ftp_sorting_prefer"
    local_end="$(date +%s)"
    local_exec_time="$((local_end - local_start))"
    total_time="$((total_time + local_exec_time))"
    echo "exec time   : $local_exec_time seconds" | tee -a "$logfile"
    echo '-------------------------------------------------------------------------' | tee -a "$logfile"

    total_time=0

    if [ "$dst_nextcloud_inst_path_handle" == "skip" -a "$dst_nextcloud_data_path_handle" == "skip" ]; then
        echo "nextcloud-mover : skipping all"
        exit_bad
    fi
	
    # get all restore candidates
    shas=$(ftp_list "$ftp_protocol" "$ftp_host" "$ftp_port" "$ftp_user" "$ftp_password" "$ftp_remote_dir" "$ftp_sorting_prefer")
    # filter only *.sha as we'll use them as toc to download
    selected=$(echo $shas | sed 's/ /\n/g' | grep sha512 | head -n 1)
    selected=${selected/$ftp_remote_dir}
    selected=${selected/.$sha512_filename_suffix}
    echo "selected $selected"

# set -x
# set +x
    
    # check if they exist on server (or exit)
    ftp_find "$ftp_protocol" "$ftp_host" "$ftp_port" "$ftp_user" "$ftp_password" "$ftp_remote_dir" "$selected"."$sha512_filename_suffix"
    if [ $? -ne 0 ]; then 
        echo "nextcloud-mover : file $selected"."$sha512_filename_suffix not exists in ftp host" 
        exit_bad
    else
        echo "nextcloud-mover : file $selected"."$sha512_filename_suffix exists in ftp host"
    fi

    ftp_find "$ftp_protocol" "$ftp_host" "$ftp_port" "$ftp_user" "$ftp_password" "$ftp_remote_dir" "$selected"."$backup_log_suffix"
    if [ $? -ne 0 ]; then 
        echo "nextcloud-mover : file $selected"."$backup_log_suffix not exists in ftp host" 
        exit_bad
    else
        echo "nextcloud-mover : file $selected"."$backup_log_suffix exists in ftp host"
    fi

    ftp_find "$ftp_protocol" "$ftp_host" "$ftp_port" "$ftp_user" "$ftp_password" "$ftp_remote_dir" "$selected"."$pg_dump_filename_suffix"
    if [ $? -ne 0 ]; then 
        echo "nextcloud-mover : file $selected"."$pg_dump_filename_suffix not exists in ftp host" 
        exit_bad
    else
        echo "nextcloud-mover : file $selected"."$pg_dump_filename_suffix exists in ftp host"
    fi

    ftp_find "$ftp_protocol" "$ftp_host" "$ftp_port" "$ftp_user" "$ftp_password" "$ftp_remote_dir" "$selected"."$nextcloud_inst_filename_suffix"
    if [ $? -ne 0 ]; then 
        echo "nextcloud-mover : file $selected"."$nextcloud_inst_filename_suffix not exists in ftp host" 
        exit_bad
    else
        echo "nextcloud-mover : file $selected"."$nextcloud_inst_filename_suffix exists in ftp host"
    fi

    ftp_find "$ftp_protocol" "$ftp_host" "$ftp_port" "$ftp_user" "$ftp_password" "$ftp_remote_dir" "$selected"."$nextcloud_data_filename_suffix"
    if [ $? -ne 0 ]; then 
        echo "nextcloud-mover : file $selected"."$nextcloud_data_filename_suffix not exists in ftp host" 
        exit_bad
    else
        echo "nextcloud-mover : file $selected"."$nextcloud_data_filename_suffix exists in ftp host"
    fi

    # download 
    ftp_download "$ftp_protocol" "$ftp_host" "$ftp_port" "$ftp_user" "$ftp_password" "$ftp_remote_dir" "$selected"."$sha512_filename_suffix"
    ftp_download "$ftp_protocol" "$ftp_host" "$ftp_port" "$ftp_user" "$ftp_password" "$ftp_remote_dir" "$selected"."$backup_log_suffix"
    ftp_download "$ftp_protocol" "$ftp_host" "$ftp_port" "$ftp_user" "$ftp_password" "$ftp_remote_dir" "$selected"."$pg_dump_filename_suffix"
    ftp_download "$ftp_protocol" "$ftp_host" "$ftp_port" "$ftp_user" "$ftp_password" "$ftp_remote_dir" "$selected"."$nextcloud_inst_filename_suffix"
    ftp_download "$ftp_protocol" "$ftp_host" "$ftp_port" "$ftp_user" "$ftp_password" "$ftp_remote_dir" "$selected"."$nextcloud_data_filename_suffix"

    # validate sha512 sum
    sha512sum -c "$selected"."$sha512_filename_suffix"
    if [ $? -ne 0 ]; then 
        echo "nextcloud-mover : sha512 checksums failed" 
        exit_bad
    else
        echo "nextcloud-mover : sha512 checksums passed"
    fi

    # make sure db does not exist (or exit)
    # make sure nextcloud installation does not exist (or exit)
    # make sure nextcloud data files do not exist (or exit)
    
    # restore db
    # restore installation
    # restore data files


}

echo_banner

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
