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
# CAUTION: DATABASE DATA LOSS
# handle database on destination, with the following options
#   skip     : do nothing, no loss
#   create   : drop and recreate everything (user, rights, database etc)
dst_db_handle="create"
dst_db_handle_valid_values=("skip" "create")
dst_db_encoding="UTF-8"
dst_db_lc_collate="en_US.UTF-8"
dst_db_lc_type="en_US.UTF-8"

# apache settings
# used for sudo -u user occ maintenance:mode
src_apache_user="www-data"
dst_apache_user="www-data"

# nextcloud source system installation and data directory
src_nextcloud_inst_path="/some/path/to/your/www/nextcloud/installation"
src_nextcloud_data_path="/some/path/to/your/nextcloud/data/directory"

# nextcloud destination system installation directory
dst_nextcloud_inst_path="/some/path/to/your/www/nextcloud/installation"
# CAUTION: FILES DATA LOSS
# handle nextcloud installation path on destination, with the following options
#   skip     : do nothing, no loss
#   create   : mkdir if it does not exist otherwise rm -rf && mkdir
#   overwite : in any case untar in path specified
dst_nextcloud_inst_path_handle="skip"
dst_nextcloud_inst_path_valid_values=("skip" "create" "overwite")
# nextcloud destination system data directory
dst_nextcloud_data_path="/some/path/to/your/nextcloud/data/directory"
# CAUTION: DATA LOSS
# same as above but for data files
dst_nextcloud_data_path_handle="skip"
dst_nextcloud_data_path_valid_values=("skip" "create" "overwite")

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

# common checks for src and dst postgres
check_postgres(){
    local l_log="$1"
    local l_pg_user="$2"
    local l_db_host="$3"
    local l_db_port="$4"
    local l_db_name="$5"
    local l_db_user="$6"
    local l_db_password="$7"
    
    # if lsof -Pi :"$l_db_port" -sTCP:LISTEN -t >/dev/null; then
    #     echo "checks      : postgres listening on port $l_db_port" | tee -a "$l_log"
    # else
    #     echo "checks      : postgres not listening port $l_db_port" | tee -a "$l_log"
    #     exit_bad
    # fi

    # make sure specific ip/host and specific port is accepting connections
    pg_isready -h "$l_db_host" -p "$l_db_port" | grep 'accepting connections' &>/dev/null
    if [ $? -eq 0 ]; then
        echo "checks      : postgres accepting connections @ $l_db_host:$l_db_port" | tee -a "$l_log"
    else
        # keep the error in log file
        pg_isready -h "$l_db_host" -p "$l_db_port" > /dev/null 2> >(tee -a "$l_log")
        echo "checks      : postgres not accepting connections $l_db_host:$l_db_port" | tee -a "$l_log"
        exit_bad
    fi   
}

check_src_postgres() {
    local l_log="$1"
    local l_pg_user="$2"
    local l_db_host="$3"
    local l_db_port="$4"
    local l_db_name="$5"
    local l_db_user="$6"
    local l_db_password="$7"

    check_postgres "$l_log" "$l_pg_user" "$l_db_host" "$l_db_port" "$l_db_name" "$l_db_user" "$l_db_password"

    if command -v pg_dump &>/dev/null; then
        echo "checks      : postgres pg_dump found" | tee -a "$l_log"
    else
        echo "checks      : pg_dump could not be found - are you sure you are running postgres in this host ?" | tee -a "$l_log"
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

check_dst_postgres() {
    local l_log="$1"
    local l_pg_user="$2"
    local l_db_host="$3"
    local l_db_port="$4"
    local l_db_name="$5"
    local l_db_user="$6"
    local l_db_password="$7"
    local l_db_handle="$8"
    local l_db_encoding="$9"
    local l_db_lc_collate="${10}"
    local l_db_lc_type="${11}"

    check_postgres "$l_log" "$l_pg_user" "$l_db_host" "$l_db_port" "$l_db_name" "$l_db_user" "$l_db_password"
    
    if command -v pg_restore &>/dev/null; then
        echo "checks      : postgres pg_restore found" | tee -a "$l_log"
    else
        echo "checks      : pg_restore could not be found - are you sure you are running postgres in this host ?" | tee -a "$l_log"
        exit_bad
    fi

    # check handle values sanity
    local db_value="\<${l_db_handle}\>"
    if [[ "${dst_db_handle_valid_values[@]}" =~ $db_value ]]; then
        echo "checks      : postgres db handle valid value found : '$l_db_handle'" | tee -a "$l_log"
    else
        echo "checks      : postgres db_handle invalid value found : '$l_db_handle'" | tee -a "$l_log"
        exit_bad
    fi

    # TODO check encoding exists
    # 
    # FIXME check collation exists
    #   echo $(locale -a | grep -E "el_GR|greek" should return
    #       el_GR
    #       el_GR.iso88597
    #       el_GR.utf8
    #       greek
    # FIXME break_bad if collation not exist
    #       echo $(locale -a | grep -E "el_GR|greek" | wc -l) should return 
    #           4
    # FIXME if collates not exist: sudo locale-gen el_GR && sudo locale-gen el_GR.UTF-8 && reboot
    # 
    # sudo -u postgres psql -c "SELECT * FROM pg_collation WHERE ... LIKE 'utf8%'

}

# common checks for src and dst nextcloud instances
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
    local l_nextcloud_inst_path_handle="$4"
    local l_nextcloud_data_path="$5"
    local l_nextcloud_data_path_handle="$6"

    # check handle values sanity
    local inst_value="\<${l_nextcloud_inst_path_handle}\>"
    if [[ "${dst_nextcloud_inst_path_valid_values[@]}" =~ $inst_value ]]; then
        echo "checks      : nextcloud inst handle valid value found : '$l_nextcloud_inst_path_handle'"
    else
        echo "checks      : nextcloud inst handle invalid value found : '$l_nextcloud_inst_path_handle'"
        exit_bad
    fi

    # check handle values sanity
    local data_value="\<${l_nextcloud_data_path_handle}\>"
    if [[ "${dst_nextcloud_data_path_valid_values[@]}" =~ $data_value ]]; then
        echo "checks      : nextcloud data handle valid value found : '$l_nextcloud_data_path_handle'"
    else
        echo "checks      : nextcloud data handle invalid value found : '$l_nextcloud_data_path_handle'"
        exit_bad
    fi

    check_nextcloud "$l_apache_user" "$l_nextcloud_inst_path" "$l_nextcloud_data_path"

    # check directory handle sanity
    if [ -d "$l_nextcloud_inst_path" ]; then
        echo "checks      : nextcloud installation exists in $l_nextcloud_inst_path" | tee -a "$l_log"
        case "$l_nextcloud_inst_path_handle" in
            skip)
                echo "checks      : nextcloud-mover will not DELETE your $l_nextcloud_inst_path"
                echo "checks      : nextcloud-mover will not CREATE path $l_nextcloud_inst_path"
                echo "checks      : nextcloud-mover will not RESTORE a backup to $l_nextcloud_inst_path"
                echo "checks      : nextcloud-mover will SKIP everyting"
                ;;
            create)
                echo "checks      : nextcloud-mover CAUTION !!! for you nextcloud installation files"
                echo "checks      : nextcloud-mover will DELETE your $l_nextcloud_inst_path"
                echo "checks      : nextcloud-mover will CREATE path $l_nextcloud_inst_path"
                echo "checks      : nextcloud-mover will RESTORE a backup to $l_nextcloud_inst_path"
                ;;
            overwrite)
                echo "checks      : nextcloud-mover CAUTION !!! for you nextcloud installation files"
                echo "checks      : nextcloud-mover will not DELETE your $l_nextcloud_inst_path"
                echo "checks      : nextcloud-mover will not CREATE path $l_nextcloud_inst_path"
                echo "checks      : nextcloud-mover will RESTORE a backup to/and OVERWITE $l_nextcloud_inst_path"
                ;;
            *)
                echo "checks      : nextcloud-mover unknown option found: $l_nextcloud_inst_path_handle"
                exit_bad
                ;;
        esac
    else
        echo "checks      : nextcloud installation does not exist in $l_nextcloud_inst_path" | tee -a "$l_log"
        case "$l_nextcloud_inst_path_handle" in
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
                echo "checks      : nextcloud-mover unknown option found: $l_nextcloud_inst_path_handle"
                exit_bad
                ;;
        esac
    fi
    
    if [ -d "$l_nextcloud_data_path" ]; then
        echo "checks      : nextcloud data exists in $l_nextcloud_data_path" | tee -a "$l_log"
        case "$l_nextcloud_data_path_handle" in
            skip)
                echo "checks      : nextcloud-mover will not DELETE your $l_nextcloud_data_path"
                echo "checks      : nextcloud-mover will not CREATE path $l_nextcloud_data_path"
                echo "checks      : nextcloud-mover will not RESTORE a backup to $l_nextcloud_data_path"
                echo "checks      : nextcloud-mover will SKIP everyting"
                ;;
            create)
                echo "checks      : nextcloud-mover CAUTION !!! for you nextcloud DATA files"
                echo "checks      : nextcloud-mover will DELETE your $l_nextcloud_data_path"
                echo "checks      : nextcloud-mover will CREATE path $l_nextcloud_data_path"
                echo "checks      : nextcloud-mover will RESTORE a backup to $l_nextcloud_data_path"
                ;;
            overwrite)
                echo "checks      : nextcloud-mover CAUTION !!! for you nextcloud DATA files"
                echo "checks      : nextcloud-mover will not DELETE your $l_nextcloud_data_path"
                echo "checks      : nextcloud-mover will not CREATE path $l_nextcloud_data_path"
                echo "checks      : nextcloud-mover will RESTORE a backup to/and OVERWITE $l_nextcloud_data_path"
                ;;
            *)
                echo "checks      : nextcloud-mover unknown option found: $l_nextcloud_data_path_handle"
                exit_bad
                ;;
        esac
    else
        echo "checks      : nextcloud data does not exist in $l_nextcloud_data_path" | tee -a "$l_log"
        case "$l_nextcloud_data_path_handle" in
            skip)
                echo "checks      : nextcloud-mover will not CREATE path $l_nextcloud_data_path"
                echo "checks      : nextcloud-mover will not RESTORE a backup to $l_nextcloud_data_path"
                echo "checks      : nextcloud-mover will SKIP everyting"
                ;;
            create)
                echo "checks      : nextcloud-mover will CREATE path $l_nextcloud_data_path"
                echo "checks      : nextcloud-mover will RESTORE a backup to $l_nextcloud_data_path"
                ;;
            overwrite)
                echo "checks      : nextcloud-mover cannot OVERWITE path $l_nextcloud_data_path that does not exist"
                exit_bad
                ;;
            *)
                echo "checks      : nextcloud-mover unknown option found: $l_nextcloud_data_path_handle"
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
        echo "checks      : ftp remote host accepting requests @ $l_ftp_host:$l_ftp_port" | tee -a "$l_log"
    else
        echo "checks      : ftp remote host not accepting requests @ $l_ftp_host:$l_ftp_port" | tee -a "$l_log"
        exit_bad
    fi

    ftp_list "$l_ftp_protocol" "$l_ftp_host" "$l_ftp_port" "$l_ftp_user" "$l_ftp_password" "$l_ftp_remote_dir" "$l_ftp_remote_sort" &>/dev/null
    if [ $? -eq 0 ]; then
        echo "checks      : ftp lftp can connect to remote host @ $ftp_host:$ftp_port" | tee -a "$l_log"
    else
        echo "checks      : ftp lftp cannot connect to remote host @ $ftp_host:$ftp_port" | tee -a "$l_log"
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
    echo 'checks      : ---' | tee -a "$logfile"
    check_src_postgres "$logfile" "$src_pg_user" "$src_db_host" "$src_db_port" "$src_db_name" "$src_db_user" "$src_db_password"
    echo 'checks      : ---' | tee -a "$logfile"
    check_src_nextcloud "$logfile" "$src_apache_user" "$src_nextcloud_inst_path" "$src_nextcloud_data_path"
    echo 'checks      : ---' | tee -a "$logfile"
    check_ftp "$logfile" "$ftp_protocol" "$ftp_host" "$ftp_port" "$ftp_user" "$ftp_password" "$ftp_remote_dir" "$ftp_sorting_prefer"
    echo 'checks      : ---' | tee -a "$logfile"
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
    echo "exec time           : $local_exec_time seconds" | tee -a "$logfile"
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

    # dump db
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
    echo "exec        : checking if $src_nextcloud_data_path is subdirectory of $src_nextcloud_inst_path" 2>&1 | tee -a "$logfile"
    if [[ $src_nextcloud_data_path = $src_nextcloud_inst_path* ]]; then 
        echo "exec        : $src_nextcloud_data_path is subdirectory of $src_nextcloud_inst_path" 2>&1 | tee -a "$logfile" 
        # subtract sane prefix path
        local exclude_data_path=${src_nextcloud_data_path#"$src_nextcloud_inst_path"}
        # prefix path with dot otherwise tar will not handle it
        exclude_data_path=".$exclude_data_path"
        tar --exclude="$exclude_data_path" \
            -C "$src_nextcloud_inst_path" \
            -cvpzf "$nextcloud_inst_bu_file" . 2>&1 | tee -a "$logfile"
    else
        echo "exec        : $src_nextcloud_data_path is not subdirectory of $src_nextcloud_inst_path" 2>&1 | tee -a "$logfile" 
        tar -C "$src_nextcloud_inst_path" \
            -cvpzf "$nextcloud_inst_bu_file" . 2>&1 | tee -a "$logfile"
    fi
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
    tar -C "$src_nextcloud_data_path" \
        -cvpzf "$nextcloud_data_bu_file" . 2>&1 | tee -a "$logfile"
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
    if [ -n "$1" ] && [ -f "$1" ]; then
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

    local sha512file
    local backup_logfile
    local pg_dump_file
    local nextcloud_inst_bu_file
    local nextcloud_data_bu_file

    # starter time counters
    local total_time
    local local_start
    local local_end
    local local_exec_time
    total_time=0
    local_start=0
    local_end=0
    local_exec_time=0

    # check if exceptional case to skip all
    local_start="$(date +%s)"
    echo "skip        : check to skip restore of db, nextcloud installation and data files" | tee -a "$logfile"
    if [ "$dst_nextcloud_inst_path_handle" == "skip" ] && [ "$dst_nextcloud_data_path_handle" == "skip" ] && [ "$dst_db_handle" == "skip" ]; then
        echo "skip        : skipping all - nothing to do here - exiting ..." | tee -a "$logfile"
        exit_bad
    else
        echo "skip        : not skipping - have got some things to do - proceeding ..." | tee -a "$logfile"
    fi
    local_end="$(date +%s)"
    local_exec_time="$((local_end - local_start))"
    total_time="$((total_time + local_exec_time))"
    echo "exec time   : $local_exec_time seconds" | tee -a "$logfile"
    echo '-------------------------------------------------------------------------' | tee -a "$logfile"

    # check settings sanity
    local_start="$(date +%s)"
    echo "checks      : starting to check settings sanity" | tee -a "$logfile"
    echo 'checks      : ---' | tee -a "$logfile"
    check_dst_postgres "$logfile" "$dst_pg_user" "$dst_db_host" "$dst_db_port" \
        "$dst_db_name" "$dst_db_user" "$dst_db_password" "$dst_db_handle" \
        "dst_db_encoding" "dst_db_lc_collate" "dst_db_lc_type"
    echo 'checks      : ---' | tee -a "$logfile"
    check_dst_nextcloud "$logfile" "$dst_apache_user" "$dst_nextcloud_inst_path" "$dst_nextcloud_inst_path_handle" "$dst_nextcloud_data_path" "$dst_nextcloud_data_path_handle"
    echo 'checks      : ---' | tee -a "$logfile"
    check_ftp "$logfile" "$ftp_protocol" "$ftp_host" "$ftp_port" "$ftp_user" "$ftp_password" "$ftp_remote_dir" "$ftp_sorting_prefer"
    echo 'checks      : ---' | tee -a "$logfile"
    local_end="$(date +%s)"
    local_exec_time="$((local_end - local_start))"
    total_time="$((total_time + local_exec_time))"
    echo "exec time   : $local_exec_time seconds" | tee -a "$logfile"
    echo '-------------------------------------------------------------------------' | tee -a "$logfile"

    # select files to download
    local_start="$(date +%s)"
    echo "select      : select files to download" | tee -a "$logfile"
    # get all restore candidates
    shas=$(ftp_list "$ftp_protocol" "$ftp_host" "$ftp_port" "$ftp_user" "$ftp_password" "$ftp_remote_dir" "$ftp_sorting_prefer")
    # filter only *.sha as we'll use them as toc to download
    selected=$(echo "$shas" | sed 's/ /\n/g' | grep sha512 | head -n 1)
    # remove leading path of ftp_remote_dir
    selected=${selected/$ftp_remote_dir}
    # remove trailing '.hash.sha512' suffix
    selected=${selected/.$sha512_filename_suffix}
    # files to download 
    sha512file="$selected"."$sha512_filename_suffix"
    backup_logfile="$selected"."$backup_log_suffix"
    pg_dump_file="$selected"."$pg_dump_filename_suffix"
    nextcloud_inst_bu_file="$selected"."$nextcloud_inst_filename_suffix"
    nextcloud_data_bu_file="$selected"."$nextcloud_data_filename_suffix"
    # treat files to download as an array
    # 1st always sha512 - will be used later as index of other files
    # 2nd always log file
    # 3rd db dump
    # 4th nextcloud installation files tar.gz
    # 5th nextcloud data files tar.gz
    local files=("$sha512file" "$backup_logfile" "$pg_dump_file" "$nextcloud_inst_bu_file" "$nextcloud_data_bu_file")
    for f in "${!files[@]}"; do
        echo "select      : [$f] ---> ${files[$f]}" | tee -a "$logfile"
    done
    local_end="$(date +%s)"
    local_exec_time="$((local_end - local_start))"
    total_time="$((total_time + local_exec_time))"
    echo "exec time   : $local_exec_time seconds" | tee -a "$logfile"
    echo '-------------------------------------------------------------------------' | tee -a "$logfile"

    # check if selected files exist on server
    echo "checks      : check if selected files exist on server (or exit)" | tee -a "$logfile"
    for f in "${!files[@]}"; do
        echo ""
        ftp_find "$ftp_protocol" "$ftp_host" "$ftp_port" "$ftp_user" "$ftp_password" "$ftp_remote_dir" "${files[$f]}"
        if [ $? -ne 0 ]; then 
            echo "checks      : [$f] ---> ${files[$f]} not exists in ftp host" | tee -a "$logfile"
            exit_bad
        else
            echo "checks      : [$f] ---> ${files[$f]} exists in ftp host" | tee -a "$logfile"
        fi
    done
    local_end="$(date +%s)"
    local_exec_time="$((local_end - local_start))"
    total_time="$((total_time + local_exec_time))"
    echo "exec time   : $local_exec_time seconds" | tee -a "$logfile"
    echo '-------------------------------------------------------------------------' | tee -a "$logfile"

    # download selected files
    local_start="$(date +%s)"
    echo "download    : download selected files " | tee -a "$logfile"
    for f in "${!files[@]}"; do
        echo "download    : [$f] ---> ${files[$f]}" | tee -a "$logfile"
        # always download and overwrite sha512 and log first
        if [ "$f" -le 1 ]; then
            ftp_download "$ftp_protocol" "$ftp_host" "$ftp_port" "$ftp_user" "$ftp_password" "$ftp_remote_dir" "${files[$f]}"
        else
            # check if it already downloaded and has the same sha512
            if [ -f "${files[$f]}" ]; then
                echo "download    : [$f] ---> ${files[$f]} exists locally - skipping" | tee -a "$logfile"
            else 
                ftp_download "$ftp_protocol" "$ftp_host" "$ftp_port" "$ftp_user" "$ftp_password" "$ftp_remote_dir" "${files[$f]}"
            fi
        fi
    done
    local_end="$(date +%s)"
    local_exec_time="$((local_end - local_start))"
    total_time="$((total_time + local_exec_time))"
    echo "exec time   : $local_exec_time seconds" | tee -a "$logfile"
    echo '-------------------------------------------------------------------------' | tee -a "$logfile"

    # validate sha512 sum
    local_start="$(date +%s)"
    echo "sha512      : validate sha512 sum " | tee -a "$logfile"
    sha512sum -c "$sha512file"
    if [ $? -ne 0 ]; then 
        echo "sha512      : sha512 checksums failed" | tee -a "$logfile"
        exit_bad
    else
        echo "sha512      : sha512 checksums passed" | tee -a "$logfile"
    fi
    local_end="$(date +%s)"
    local_exec_time="$((local_end - local_start))"
    total_time="$((total_time + local_exec_time))"
    echo "exec time   : $local_exec_time seconds" | tee -a "$logfile"
    echo '-------------------------------------------------------------------------' | tee -a "$logfile"

    # restore db
    local_start="$(date +%s)"
    sudo -u postgres psql -lqt | cut -d \| -f 1 | grep -qw "$dst_db_name"
    if [ $? -eq 0 ]; then
        echo "db restore  : postgres db '$dst_db_name' already exists in $dst_db_host" | tee -a "$logfile"
    else
        echo "db restore  : postgres db '$dst_db_name' does not exist in $dst_db_host" | tee -a "$logfile"
    fi

    echo "db restore  : nextcloud-mover detected 'dst_db_handle=$dst_db_handle'" | tee -a "$logfile"
    case "$dst_db_handle" in
        skip)
            echo "db restore  : nextcloud-mover will not DROP and CREATE your database '$dst_db_name'" | tee -a "$logfile"
            echo "db restore  : nextcloud-mover will not DROP and CREATE your user '$dst_db_user'" | tee -a "$logfile"
            echo "db restore  : nextcloud-mover will not GRANT rights to your user '$dst_db_user'" | tee -a "$logfile"
            echo "db restore  : nextcloud-mover will not RESTORE a db dump to '$dst_db_name'" | tee -a "$logfile"
            echo "db restore  : nextcloud-mover will SKIP everyting" | tee -a "$logfile"
            ;;
        create)
            echo "db restore  : nextcloud-mover CAUTION !!! for you nextcloud database" | tee -a "$logfile"
            echo "db restore  : nextcloud-mover will DROP and CREATE your '$dst_db_name' database" | tee -a "$logfile"
            sudo -u "$dst_pg_user" psql -c "DROP DATABASE IF EXISTS $dst_db_name;" 2>&1 | tee -a "$logfile"
            # Another common reason for copying template0 instead of template1 
            # is that new encoding and locale settings can be specified when 
            # copying template0, whereas a copy of template1 must use the same 
            # settings it does. This is because template1 might contain 
            # encoding-specific or locale-specific data, while template0 is 
            # known not to. 
            # https://www.postgresql.org/docs/10/manage-ag-templatedbs.html
            sudo -u "$dst_pg_user" psql -c "CREATE DATABASE nextcloud WITH ENCODING='$dst_db_encoding' LC_COLLATE '$dst_db_lc_collate' LC_CTYPE '$dst_db_lc_type' TEMPLATE=template0;" 2>&1 | tee -a "$logfile"
            echo "db restore  : nextcloud-mover will DROP and CREATE user '$dst_db_user' and GRANT rights" | tee -a "$logfile"
            sudo -u "$dst_pg_user" psql -c "DROP ROLE IF EXISTS $dst_db_user;" 2>&1 | tee -a "$logfile"
            sudo -u "$dst_pg_user" psql -c "CREATE ROLE $dst_db_user WITH LOGIN ENCRYPTED PASSWORD '$dst_db_password';" 2>&1 | tee -a "$logfile"
            sudo -u "$dst_pg_user" psql -c "GRANT ALL PRIVILEGES ON DATABASE $dst_db_name TO $dst_db_user;" 2>&1 | tee -a "$logfile"
            sudo -u "$dst_pg_user" psql -c "ALTER DATABASE $dst_db_name OWNER TO $dst_db_user" 2>&1 | tee -a "$logfile"   
            echo "db restore  : nextcloud-mover will RESTORE a db dump to '$dst_db_name'" | tee -a "$logfile"
            sudo -u "$dst_pg_user" psql --set ON_ERROR_STOP=on -d "$dst_db_name" -f "$pg_dump_file" 2>&1 | tee -a "$logfile"
            ;;
        *)
            echo "db restore  : uknown" | tee -a "$logfile"
            exit_bad
            ;;
    esac
    local_end="$(date +%s)"
    local_exec_time="$((local_end - local_start))"
    total_time="$((total_time + local_exec_time))"
    echo "exec time   : $local_exec_time seconds" | tee -a "$logfile"
    echo '-------------------------------------------------------------------------' | tee -a "$logfile"

    # restore installation files
    local_start="$(date +%s)"
    echo "restore     : installation files restoring in $dst_nextcloud_inst_path" | tee -a "$logfile"
    case "$dst_nextcloud_inst_path_handle" in
        skip)
            echo "restore     : nextcloud-mover will not DELETE the nextcloud installation directory '$dst_nextcloud_inst_path'" | tee -a "$logfile"
            echo "restore     : nextcloud-mover will not CREATE a nextcloud installation directory at '$dst_nextcloud_inst_path'" | tee -a "$logfile"
            echo "restore     : nextcloud-mover will not RESTORE a nextcloud installation backup at '$dst_nextcloud_inst_path'" | tee -a "$logfile"
            echo "restore     : nextcloud-mover will SKIP everyting" | tee -a "$logfile"        
            ;;
        create)
            #TODO config file echo "restore     : nextcloud-mover will BACKUP the nextcloud config.php" | tee -a "$logfile"
            #TODO config file mv "$dst_nextcloud_inst_path"/config/config.php . | tee -a "$logfile"
            echo "restore     : nextcloud-mover will DELETE the nextcloud installation directory '$dst_nextcloud_inst_path'" | tee -a "$logfile"
            rm -rf "$dst_nextcloud_inst_path" 2>&1 | tee -a "$logfile"
            echo "restore     : nextcloud-mover will CREATE a nextcloud installation directory at '$dst_nextcloud_inst_path'" | tee -a "$logfile"
            mkdir -p "$dst_nextcloud_inst_path" 2>&1 | tee -a "$logfile"
            echo "restore     : nextcloud-mover will RESTORE a nextcloud installation backup at '$dst_nextcloud_inst_path'" | tee -a "$logfile"
            tar -xvf "$nextcloud_inst_bu_file" -C "$dst_nextcloud_inst_path" 2>&1 | tee -a "$logfile"
            #TODO config file echo "restore     : nextcloud-mover will RESTORE the nextcloud config.php" | tee -a "$logfile"
            #TODO config file mv ./config.php "$dst_nextcloud_inst_path"/config/ | tee -a "$logfile"
            ;;
        overwrite)
            echo "restore     : nextcloud-mover will not DELETE the nextcloud installation directory '$dst_nextcloud_inst_path'" | tee -a "$logfile"
            echo "restore     : nextcloud-mover will not CREATE a nextcloud installation directory at '$dst_nextcloud_inst_path'" | tee -a "$logfile"
            echo "restore     : nextcloud-mover will RESTORE and overwrite a nextcloud installation backup at '$dst_nextcloud_inst_path'" | tee -a "$logfile"
            tar -xvf "$nextcloud_inst_bu_file" -C "$dst_nextcloud_inst_path" 2>&1 | tee -a "$logfile"
            ;;
        *)
            echo "restore     : uknown" | tee -a "$logfile"
            exit_bad
            ;;
    esac
    local_end="$(date +%s)"
    local_exec_time="$((local_end - local_start))"
    total_time="$((total_time + local_exec_time))"
    echo "exec time   : $local_exec_time seconds" | tee -a "$logfile"
    echo '-------------------------------------------------------------------------' | tee -a "$logfile"    

    # restore data files
    local_start="$(date +%s)"
    echo "restore     : data files restoring in $dst_nextcloud_data_path" | tee -a "$logfile"
    case "$dst_nextcloud_data_path_handle" in
        skip)
            echo "restore     : nextcloud-mover will not DELETE the nextcloud data directory '$dst_nextcloud_data_path'" | tee -a "$logfile"
            echo "restore     : nextcloud-mover will not CREATE a nextcloud data directory at '$dst_nextcloud_data_path'" | tee -a "$logfile"
            echo "restore     : nextcloud-mover will not RESTORE a nextcloud data backup at '$dst_nextcloud_data_path'" | tee -a "$logfile"
            echo "restore     : nextcloud-mover will SKIP everyting" | tee -a "$logfile"         
            ;;
        create)
            echo "restore     : nextcloud-mover will DELETE the nextcloud data directory '$dst_nextcloud_data_path'" | tee -a "$logfile"
            rm -rf "$dst_nextcloud_data_path" 2>&1 | tee -a "$logfile"
            echo "restore     : nextcloud-mover will CREATE a nextcloud data directory at '$dst_nextcloud_data_path'" | tee -a "$logfile"
            mkdir -p "$dst_nextcloud_data_path" 2>&1 | tee -a "$logfile"
            echo "restore     : nextcloud-mover will RESTORE a nextcloud data backup at '$dst_nextcloud_data_path'" | tee -a "$logfile"
            tar -xvf "$nextcloud_data_bu_file" -C "$dst_nextcloud_data_path" 2>&1 | tee -a "$logfile"
            ;;
        overwrite)
            echo "restore     : nextcloud-mover will not DELETE the nextcloud data directory '$dst_nextcloud_data_path'" | tee -a "$logfile"
            echo "restore     : nextcloud-mover will not CREATE a nextcloud data directory at '$dst_nextcloud_data_path'" | tee -a "$logfile"        
            echo "restore     : nextcloud-mover will RESTORE a nextcloud data backup at '$dst_nextcloud_data_path'" | tee -a "$logfile"
            tar -xvf "$nextcloud_data_bu_file" -C "$dst_nextcloud_data_path" 2>&1 | tee -a "$logfile"
            ;;
        *)
            echo "db restore  : uknown" | tee -a "$logfile"
            exit_bad
            ;;
    esac
    local_end="$(date +%s)"
    local_exec_time="$((local_end - local_start))"
    total_time="$((total_time + local_exec_time))"
    echo "exec time   : $local_exec_time seconds" | tee -a "$logfile"
    echo '-------------------------------------------------------------------------' | tee -a "$logfile"    

    # set occ maintenance:mode / tar.gz backup gets created in src system when maintenance:mode is on
    local_start="$(date +%s)"
    echo "restore     : occ maintenance:mode --off" | tee -a "$logfile"
    sudo -u www-data php "$dst_nextcloud_inst_path"/occ maintenance:mode --off 2>&1 | tee -a "$logfile"
    local_end="$(date +%s)"
    local_exec_time="$((local_end - local_start))"
    total_time="$((total_time + local_exec_time))"
    echo "exec time   : $local_exec_time seconds" | tee -a "$logfile"
    echo '-------------------------------------------------------------------------' | tee -a "$logfile"

    echo "total time  : $total_time seconds" | tee -a "$logfile"

# set -x
# set +x

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
