#!/bin/bash

echo "Simple backup script"
echo "Databases, apps, etc and scp them to specific host"

# get ISO 8601 timestamp
timestamp=$(date +"%Y%m%dT%H%M%SZ")

# stop postgresql 10 and backup database data directory
systemctl stop postgresql

tar -zcvf "$timestamp".postgres.10.data-directory.tar.gz /var/lib/postgresql/10/main

# pgdump important dbs
# nextcloud
echo "pg_dump db:nextcloud"
pg_dump -U database_user -W -F t nextcloud > "$timestamp".nextcloud.db.tar

systemctl start postgresql




