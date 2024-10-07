set ip's that won't get banned
```
$ sudo nano /etc/fail2ban/jail.local
```

check who is banned
```
$ sudo zgrep 'Ban' /var/log/fail2ban.log | less
```

unban from all jails specific ip
```
$ sudo fail2ban-client unban --all 11.12.14.19
```

check who's is banned on a jail
```
$ sudo fail2ban-client status apache-noscript

```

show jails
```
$ sudo fail2ban-client status
```

ban specific ip for jail apache-noscript
```
$ sudo fail2ban-client -vvv set apache-noscript banip WW.XX.YY.ZZ
```


systemd stuff
```
$ sudo systemctl status fail2ban
$ sudo systemctl restart fail2ban
$ sudo systemctl stop fail2ban
$ sudo systemctl start fail2ban
```

