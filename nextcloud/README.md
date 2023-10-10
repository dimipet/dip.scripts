# nextcloud + postgres move 

## Use case
move a running nextcloud instance along with user files and its postgresql db and from a host (source) to another host (destination). 

## Hosts involved
The script needs 3 hosts to run:

1. a source host : This is the host where nextcloud and postgres are running now. Variables prefixed with src refer to this host's settings. The backup action uses this host to dump the postgres database and the nextcloud instance and files.
2. an ftp host : This is the host where the source host backups and uploads the postgres dump files and nextcloud files. This is also the host from where the destination hosts picks and restores the postgres dumps and the nextcloud files from. Variables prefixed with ftp refer to this host's settings.
3. a destination host : This is the (new) host where you plan to move the nextcloud and postgres. Variables prefixed with dst refer to this host's settings. The restore action uses this host to restore the postgres database to and the nextcloud files to.

## Usual process
The above are accomplished by a 4 step process:

1. source host: run backup and create db dumps + nextcloud files
2. source host: upload db dumps + nextcloud files to ftp host
3. dest host: download db dumps + nextcloud files from ftp host
4. dest host: restore db dumps + nextcloud files

# WARNINGS

## restore is destructive, 
Restore will drop the destination's host database specified in the settings and will also rm -rf all your files under the destination nextcloud path specified. Make sure you understand the script and the settings before running.
    
## nextcloud offline time
Backup will put source host nextcloud in maintenance mode and all users will loose access while it is running. Execution (offline) time of source host depends on how large your database is, how many nextcloud files are being hosted, and how fast all will these get tranfered to the ftp host.
