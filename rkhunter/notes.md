# install
```
$ sudo apt install rkhunter
```
# test run
```
$ sudo rkhunter --update --check --cronjob --report-warnings-only
Invalid WEB_CMD configuration option: Relative pathname: "/bin/false"
```

# configure
make sure that rkhunter [1]  

1. updates mirrors when `--update` is invoked
2. uses any mirror to update
3. sends email to root with warnings
4. does not restrict updates (`WEB_CMD="/bin/false"`)
5. set your package manager otherwise you'll get warnings [2]

```
$ sudo vim /etc/rkhunter.conf
UPDATE_MIRRORS=1
MIRRORS_MODE=0
MAIL-ON-WARNING=root
WEB_CMD=""
PKGMGR=DPKG
SUSPSCAN_TEMP=/dev/shm
```

# configure apt
after `apt upgrade` you will receive messages that files have changed  
configure your package manager  

```
$ sudo vim /etc/rkhunter.conf
PKGMGR=DPKG
```
and in /etc/default/rkhunter set
```
APT_AUTOGEN="true"
```

you can of course run manually after every apt update && apt upgrade
```
$ sudo rkhunter --update --propupd
```

# allow well known
rkhunter false positives such as java prefs [3], firefox, etc

```
$ sudo vim /etc/rkhunter.conf
ALLOWHIDDENDIR=/etc/.java
ALLOWIPCPROC=/usr/bin/firefox
ALLOWDEVFILE=/dev/shm/PostgreSQL.*
```

# schedule regular scans
```
$ sudo crontab -e
26 08 * * * /usr/bin/rkhunter --update --check --cronjob --report-warnings-only

```

# sshd note
rkhunter will cry if `PermitRootLogin` is not the same in `/etc/ssh/sshd_config` and `rkhunter.conf`

First understand what you should set in `/etc/ssh_config`. According to `sshd_config` man page [4]  
> **`PermitRootLogin`** Specifies whether root can log in using *ssh*(1).  The
>  argument must be **yes**, **prohibit-password**, **forced-commands-only**, or **no**.The default is **prohibit-password**.  
>  
> If this option is set to **prohibit-password** (or its deprecated alias, **without-password**), password and keyboard-interactive authentication are disabled for root.  

In this setup we suppose that `prohibit-password` is a good choice and we will use it, but:
1. Make sure you use some user (even with sudo privilege) to ssh  
2. Make sure you **don't** use explicitly `root` to ssh  

Then go ahead and set/uncomment `PermitRootLogin` on both files as follows
```
$ sudo vim /etc/ssh/sshd_config
PermitRootLogin prohibit-password

$ sudo vim /etc/rkhunter.conf
ALLOW_SSH_ROOT_USER=prohibit-password
```

Then restart the service 
```
$ sudo systemctl restart sshd.service

```
and confirm your ssh login
```
$ ssh -o PreferredAuthentications=password -o PubkeyAuthentication=no some-user@vm96.dimipet.com
```
In the example above we have disabled key login with the two options (`-o`) provided

# references
[1] https://unix.stackexchange.com/questions/562560/invalid-web-cmd-configuration-option-relative-pathname-bin-false  
[2] https://unix.stackexchange.com/questions/373718/rkhunter-gives-me-a-warning-for-usr-bin-lwp-request-what-should-i-do-debi  
[3] https://askubuntu.com/questions/1537/rkhunter-warning-about-etc-java-etc-udev-etc-initramfs  
[4] https://man7.org/linux/man-pages/man5/sshd_config.5.html


[1]: https://unix.stackexchange.com/questions/562560/invalid-web-cmd-configuration-option-relative-pathname-bin-false
[2]: https://unix.stackexchange.com/questions/373718/rkhunter-gives-me-a-warning-for-usr-bin-lwp-request-what-should-i-do-debi
[3]: https://askubuntu.com/questions/1537/rkhunter-warning-about-etc-java-etc-udev-etc-initramfs
[4]: https://man7.org/linux/man-pages/man5/sshd_config.5.html

