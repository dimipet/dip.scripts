# set hostname 
first you have to set the hostname correctly  
you can check the notes below for the different 127.0.0.* used [1]
```
$ sudo cp /etc/hostname /etc/hostname.bak
$ sudo vim /etc/hostname
vm01.qa.dimipet.com

$ sudo vim /etc/hosts
127.0.0.1       localhost
127.0.0.2       001-VM-DEBIAN-TEST
127.0.1.1       vm01.qa.dimipet.com
127.0.1.2       test.example.com

::1     localhost ip6-localhost ip6-loopback
ff02::1 ip6-allnodes
ff02::2 ip6-allrouters
```

line 1 stays for default `localhost`  
line 2 stays for old `hostname` set at early vm setup  
line 3 stays for default `FQDN`  
line 3 stays for a second `FQDN`  

reboot and check if ok
```
$ sudo reboot
$ hostname
vm01.qa.dimipet.com
```

# DNS zone
make sure the FQDN and its pointer is listed in your DNS zone  
note the first two lines
```
|--------------------|-------|---------------------|
|11.200.111.201/24   | PTR   | vm01.qa.dimipet.com.|
|vm01.qa.dimipet.com.| A     | 11.200.111.201      |
|qa.dimipet.com.     | A     | 11.200.111.197      |
|www.dimipet.com     | CNAME | qa.dimipet.com      |
|--------------------|-------|---------------------|
```
# install postfix
```
$ sudo apt install mailutils

| Setting                      | Value                                                 |
|------------------------------|-------------------------------------------------------|
| configuration type           | internet site                                         |
| system mail name             | vm01.qa.dimipet.com                                   |
| Recipient for root/postmaster| devops@dimipet.com                                    |
| Other destinations           | vm01.qa.dimipet.com, localhost.localdomain, localhost |
| Force synch upd mail queue?  | no                                                    |
| Local networks               | default (127.0.0.0/8 [::ffff:127.0.0.0]/104 [::1]/128)|
| Mailbox size limit (bytes)   | default                                               |
| Local address ext char       | default                                               |
| Internet protocols to use    | all                                                   |
```

check values you used in main.cf
```
$ sudo vim /etc/postfix/main.cf
```

# reconfigure postfix
if you already have postfix install you can reconfigure it
```
$ sudo dpkg-reconfigure postfix
```

# main.cf
```
$ sudo vim /etc/postfix/main.cf
$ sudo systemctl reload postfix
```


# setup mail forward
forward all email going to root and user01 (sudoer) to external mail
```
$ sudo vim /etc/aliases
postmaster:    root
admin:  root
www-data: root
root: devops@dimipet.com

$ sudo newaliases
$ sudo systemctl restart postfix && sudo postfix reload
```

# send a test message
```
$ echo "Testing my new postfix setup" | mail -s "Test email from `hostname`" root
```

# troubleshoot
```
$ most /var/log/mail.log
$ tail -f /var/log/mail.log
$ mailq
$ sudo mailq
```
1st mailq is for current user emails, second is for root's


# notes about 127.0.0.1
the loopback range 127/8 is 127.0.0.0 - 127.255.255.255
ALL ips in this range are bound to the loopback iface
according to ref.1 
```
The IP address 127.0.1.1 in the second line of this example may not be found on some other Unix-like systems. 
The Debian Installer creates this entry for a system without a permanent IP address as a workaround for some 
software (e.g., GNOME) as documented in the bug #719621.

The host_name matches the hostname defined in the "/etc/hostname" (see Section 3.7.1, “The hostname”).

For a system with a permanent IP address, that permanent IP address should be used here instead of 127.0.1.1.

For a system with a permanent IP address and a fully qualified domain name (FQDN) provided by the Domain Name
System (DNS), that canonical host_name.domain_name should be used instead of just host_name.
```


# refs
[1]: https://www.debian.org/doc/manuals/debian-reference/ch05.en.html#_the_hostname_resolution
