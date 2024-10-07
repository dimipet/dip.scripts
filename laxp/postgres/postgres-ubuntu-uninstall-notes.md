# uninstall 16
check policies, repos, and use dip.scripts to check what port is used and if db empty 
```
$ sudo systemctl status postgresql@16-main.service
$ sudo apt policy postgresql-16
$ postgres-list-ports-used.sh
$ postgres-list-databases-per-cluster.sh
```
purge uninstall
```
$ sudo apt purge --dry-run postgresql-16 postgresql-client-16
$ sudo apt purge postgresql-16 postgresql-client-16
$ sudo apt autoremove
```
check if leftovers and purge
```
$ dpkg --listfiles postgresql-16
$ sudo dpkg --purge postgresql-16
```
check if conf files exist and delete
```
$ cd /etc/postgresql && ls -la
$ sudo rm -rf ./16
$ /var/lib/postgresql
$ sudo rm -rf ./16
```
# unistall repos
check your repos
```
grep -h ^deb /etc/apt/sources.list /etc/apt/sources.list.d/*
```

# references
[1]: https://www.squash.io/step-by-step-process-to-uninstall-postgresql-on-ubuntu/

[1] https://www.squash.io/step-by-step-process-to-uninstall-postgresql-on-ubuntu/