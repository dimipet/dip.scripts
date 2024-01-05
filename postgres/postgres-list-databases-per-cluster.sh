#!/bin/bash

ports=""
for i in $(systemctl status postgresql* | grep config_file | cut -d'=' -f2); do
  ports+="$(grep 'port =' $i | cut -d'#' -f1 | cut -d'=' -f2 | tr -d ' ' | tr -d '\t') "
done

IFS=' ' read -r -a array <<< "$ports"

for port in "${array[@]}"; do
  echo "$(sudo -u postgres psql -t -p $port -c "SELECT current_setting('cluster_name'), current_setting('server_version');") \
    [port:$port] has these databases : \
    [$(sudo -u postgres psql -t -p $port -c "SELECT string_agg(datname, ' ') dbs FROM pg_database;")]" | sed -e 's/[[:space:]]^*//'
done
