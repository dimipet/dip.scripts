you get warnings like
```
/etc/cron.daily/chkrootkit: 

WARNING: /etc/chkrootkit.conf is deprecated. Please put your settings in /etc/chkrootkit/chkrootkit.conf instead: /etc/chkrootkit.conf will be ignored in a future release and should be deleted. 
```

first diff logically to see differences between `/etc/chkrootkit.conf` and `/etc/chkrootkit/chkrootkit.conf`  

check if `RUN_DAILY`, `RUN_DAILY_OPTS`, `DIFF_MODE` are set according to your needs  

apply your settings in `/etc/chkrootkit/chkrootkit.conf`  

delete old conf file
```
$ sudo rm /etc/chkrootkit.conf 
```
check that everything runs smooth
```
$ sudo test -x /usr/sbin/anacron || ( cd / && sudo run-parts --report /etc/cron.daily )
```
