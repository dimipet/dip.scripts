#!/bin/bash

echo "Simple move script for postgres-10 data drectory"

# refs
# https://www.postgresql.org/docs/current/continuous-archiving.html#BACKUP-LOWLEVEL-BASE-BACKUP
# https://unix.stackexchange.com/questions/252516/tar-exclude-from-double-star-wildcard

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
    set net:timeout 5; \
    set net:max-retries 2; \
    set net:reconnect-interval-base 5; \
    set xfer:verify true; \
	put -O $l_ftp_remote_dir $l_ftp_file; \
   " \
        -u "$l_ftp_user","$l_ftp_password" "$l_ftp_protocol"://"$l_ftp_host":"$l_ftp_port"
}


# get running dir
running_dir="$(pwd)"
# get script dir
script_dir="$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"

echo "running dir : $running_dir"
echo "script dir  : $script_dir"

# application properties get by cli argument 
app_properties=$1
echo "props file  : $app_properties"

if [[ -f "$app_properties" ]]; then
	echo "props file  : found, sourcing ..."
	source "$app_properties"
else
  	echo "props file  : not found, exiting ..."
  	exit -1
fi

# get ISO 8601 timestamp
timestamp=$(date +"%Y%m%dT%H%M%SZ")
common_filename="$timestamp.postgres.$postgres_version.data-directory"
data_dir_file="$local_backup_dir/$common_filename.tar.gz"
data_dir_file_sha512sum="$local_backup_dir/$common_filename.sha256.sum"
backup_log="$local_backup_dir/$common_filename.log"

# # create log file
touch "$backup_log"
echo "$timestamp" > "$backup_log"
uname -ar >> "$backup_log"

# stop postgresql 10
echo "# stopping postgres"
systemctl stop postgresql >> "$backup_log" 2>&1
systemctl status postgresql >> "$backup_log" 2>&1

# sleep needed
echo "# sleeping for a while"
sleep 15

# and backup database data directory tar gz it
echo "# backup database data directory"
tar -zcvf "$data_dir_file" "$postgres_data_dir" >> "$backup_log" 2>&1

# if we were to backup we should exclude
# experimental dont use yet
#tar -zcvf $data_dir_file \
#--exclude="/var/lib/postgresql/10/main/pg_wal/" \
#--exclude="/var/lib/postgresql/10/main/pg_replslot/" \
#--exclude="/var/lib/postgresql/10/main/pg_dynshmem/*" \
#--exclude="/var/lib/postgresql/10/main/pg_notify/*" \
#--exclude="/var/lib/postgresql/10/main/pg_serial/*" \
#--exclude="/var/lib/postgresql/10/main/pg_snapshots/*" \
#--exclude="/var/lib/postgresql/10/main/pg_stat_tmp/*" \
#--exclude="/var/lib/postgresql/10/main/pg_subtrans/*" \
#--exclude="/var/lib/postgresql/10/main/postmaster.pid" \
#--exclude="/var/lib/postgresql/10/main/postmaster.opts" \
#--exclude="*/pgsql_tmp" \
#--exclude="*/pg_internal.init" \
#/var/lib/postgresql/10 >> $backup_log 2>&1

# start postgres
echo "# starting postgres"
systemctl start postgresql >> "$backup_log" 2>&1
systemctl status postgresql >> "$backup_log" 2>&1

echo "# hashing"
sha512sum "$data_dir_file" > "$data_dir_file_sha512sum"

ftp_upload "$ftp_protocol" "$ftp_host" "$ftp_port" "$ftp_user" "$ftp_password" "$ftp_remote_dir" "$data_dir_file"
ftp_upload "$ftp_protocol" "$ftp_host" "$ftp_port" "$ftp_user" "$ftp_password" "$ftp_remote_dir" "$data_dir_file_sha512sum"
ftp_upload "$ftp_protocol" "$ftp_host" "$ftp_port" "$ftp_user" "$ftp_password" "$ftp_remote_dir" "$backup_log"


