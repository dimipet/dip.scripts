you get warnings like
```
/etc/cron.daily/chkrootkit:
No file /var/log/chkrootkit/log.expected
This file should contain expected output from chkrootkit

Today's run produced the following output:
...
To create this file containing all output from today's run, do (as root)
# cp -a /var/log/chkrootkit/log.today /var/log/chkrootkit/log.expected
# (note that unedited output is in /var/log/chkrootkit/log.today.raw)

```

proceed as follows
```
$ sudo cp -a /var/log/chkrootkit/log.today /var/log/chkrootkit/log.expected

```
