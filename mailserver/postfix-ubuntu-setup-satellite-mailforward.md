# Use case

specs

- host with dynamic (or static) ip
- forward all root emails to an an email address e.g. `admin@some-other-domain.com` 
- we do not own `some-other-domain.com` 
- we own `dimipet.com` and we use `vm01.dimipet.com` subdomain for this host
- emails sent from localhost should be originated from `vm01.dimipet.com` like this `root@vm01.dimipet.com`
- local users should be able to read local emails (`mail`)

postfix will **deliver locally**

- to `user01`
- to `user01@localhost`
- to `user01@localhost.localdomain`
- to `user01@localhost.dimipet.com`
- to `user01@vm01.dimipet.com`

postfix will **relay to satellite**

- for `foo@some-other-domain.com`
- for `doo@gmail.com`

A postfix compatible configuration for this is to use the so called satellite system.

## Prerequisites
1. your own domain name + ability to edit DNS zone, add subdomain etc
2. twillio + sendgrid account as smarthost

## Satellite System
Satellite system consists of a postfix local installation and a relay server. In this setup your postfix receives emails but doesn’t send them directly to the destination email address. Instead he delegates a relay server to send his emails to the recipients. This relay server is called "smarthost". In this setup we will be using sendgrid as smarthost.

## Files involved
1. `/etc/hostname` local system hostname, used by systemd at boot [4]
2. `/etc/hosts` name resolution multiple localhost names etc. [1]
3. `/etc/mailname` contains the visible mail name of the system [3]
4. `/etc/postfix/main.cf` basic postfix conf
5. `/etc/postfix/sasl_passwd` store credentials to access relay server

# Hostname
You have to make sure that the subdomain name that will be used through out this setup stays the same for all :

- `$ hostname`
- `/etc/hosts` 
- `/etc/mailname` 
- `/etc/postfix/main.cf` 
- `DNS zone `

First you have to set the hostname correctly. You can check the notes below for the different 127.0.0.* used [1]. At least one ip address in 127/8 has to use your subdomain.
```
$ sudo cp /etc/hostname /etc/hostname.bak
$ sudo vim /etc/hostname
vm01.dimipet.com

$ sudo vim /etc/hosts
127.0.0.1       localhost
127.0.0.2       001-VM-DEBIAN-TEST
127.0.1.1       vm01.dimipet.com
127.0.1.2       test.example.com

::1     localhost ip6-localhost ip6-loopback
ff02::1 ip6-allnodes
ff02::2 ip6-allrouters
```

line 1 stays for default `localhost`  
line 2 stays for old `hostname` set at early setup  
line 3 stays for default `FQDN`  
line 3 stays for a second `FQDN`  

reboot and check
```
$ sudo reboot
$ hostname
vm01.dimipet.com
```

# Sendgrid and DNS setup 
Sendgrid is a twillio service that can act as free smarthost to relay emails.

## Sendgrid (twillio) account
1. register
2. create restricted api key only for emails
3. note key name, key id and key (showed only once)

## DNS zone setup + sendgrid domain authentication
When you setup you domain authentication [5] you have to use the exact domain name or subdomain you used in `/etc/hosts`

First let's find the NS that serves your domain
```
$ dig dimipet.com NS
;; ANSWER SECTION:
dimipet.com.		3600	IN	NS	dns1.example.com.
dimipet.com.		3600	IN	NS	dns2.example.com.
```

Follow the steps below

1. go to your DNS provider, edit your DNS zone and create a CNAME `vm01.dimipet.com` pointing to e.g. `dimipet.com`
2. go to sendgrid - settings - sender authentication and 
    - click authenticate your domain
    - in DNS host choose `other` and use `dns1.example.com` and click next
    - in Domain You Send From use `vm01.dimipet.com`and click next
    - you will be presented with CNAMES and TXT records 
4. go to your DNS provider and create these CNAMES and TXT records on your DNS zone
5. go to sendgrid and click verify

# Postfix
After handling your DNS and sendgrid it's time to install your local postfix.

## Install postfix
Install and choose below options and values. Don't worry too much about the values used here (e.g. `internet site`). You will change `main.cf` directly later.

```
$ sudo apt install mailutils postfix libsasl2-modules

| Setting                      | Value                                                                    |
|------------------------------|--------------------------------------------------------------------------|
| configuration type           | internet site                                                            |
| system mail name             | vm01.dimipet.com                                                         |
| Recipient for root/postmaster| dimi@dimipet.com                                                         |
| Other destinations           | vm01.dimipet.com, localhost.dimipet.com, localhost.localdomain, localhost|
| Force synch upd mail queue?  | no                                                                       |
| Local networks               | default (127.0.0.0/8 [::ffff:127.0.0.0]/104 [::1]/128)                   |
| Mailbox size limit (bytes)   | default                                                                  |
| Local address ext char       | default                                                                  |
| Internet protocols to use    | all                                                                      |
```
Note that:

1. system mail stays the same as in `/etc/hosts` and `hostname`
2. local network is loopback-only to secure that others hosts on network cannot send using postfix
3. mailbox size 0 is unlimited

## Reconfigure postfix
if you already have postfix install you can reconfigure it
```
$ sudo dpkg-reconfigure postfix
```

## Configure mailname
Some debian-based installations create the `/etc/mailname` file. If this is not the case maybe you have to create the file.
```
$ touch /etc/mailname
$ chmod 644 /etc/mailname 
```
Edit the file and use the same name as used in `/etc/hosts`
```k
$ sudo vim /etc/mailname
vm01.dimpet.com
```
## Configure myhostname and myorigin
According to [2] 
```
Set myhostname to hostname.example.com, in case the machine name isn't set to a fully-qualified domain name 
(use the command postconf -d myhostname to find out what the machine name is). The myhostname value also 
provides the default value for the mydomain parameter (here, "mydomain = example.com").

Send mail as "user@example.com" (instead of "user@hostname.example.com"), so that nothing ever has a reason 
to send mail to "user@hostname.example.com".
```
Your domainname and mailname should match that used in `/etc/hosts`
Your emails should originate from your subdomain set in `/etc/mailname`, i.e. `vm01.dimipet.com`.
```
$ hostname
vm01.dimpet.com

$ postconf -d myhostname
myhostname = vm01.dimipet.com

$ sudo vim /etc/postfix/main.cf
myhostname = vm01.dimipet.com
myorigin = /etc/mailname
```

restart
```
$ sudo systemctl restart postfix
$ sudo postfix reload
```

## Configure postfix main.cf
According to [7] postfix will relay only non-local mails to the relayhost. 
```
relayhost (default: empty) The next-hop destination(s) for non-local mail; 
```

To consider a domain local it has to be listed under `$mydestination` parameter.
In the example below, postfix will NOT relay emails with destination to `dimipet.com`.
Instead it will deliver them locally.
```
mydestination = $myhostname, localhost.localdomain, localhost
```

Check that your `/etc/main.cf` is as follows
```
smtpd_relay_restrictions = permit_mynetworks permit_sasl_authenticated defer_unauth_destination
myhostname = vm01.dimipet.com
mydomain = dimipet.com
myorigin = /etc/mailname
alias_maps = hash:/etc/aliases
alias_database = hash:/etc/aliases
mydestination = $myhostname, localhost.$mydomain, localhost.localdomain, localhost
mynetworks = 127.0.0.0/8 [::ffff:127.0.0.0]/104 [::1]/128
mailbox_size_limit = 0
recipient_delimiter = +
inet_interfaces = loopback-only
default_transport = smtp
relay_transport = smtp
inet_protocols = all
```

## Configure postfix for sendgrid
According to sendgrid docs [5] add this to `/etc/postfix/main.cf`  and be sure to comment out previous lines that have the same settings (e.g. `smtpd_tls_security_level `).
```
$ sudo vim /etc/postfix/main.cf

smtp_sasl_auth_enable = yes
smtp_sasl_password_maps = hash:/etc/postfix/sasl_passwd
smtp_sasl_security_options = noanonymous
smtp_sasl_tls_security_options = noanonymous
smtp_tls_security_level = encrypt
header_size_limit = 4096000
relayhost = [smtp.sendgrid.net]:587
```
Check values using postconf and edit `main.cf` accordingly
```
$ postconf -n
$ sudo vim /etc/postfix/main.cf
```

## Configure postfix to use sendgrid API key
According to sendgrid docs [5] add this one line to `/etc/postfix/sasl_passwd`
```
$ sudo vim /etc/postfix/sasl_passwd

[smtp.sendgrid.net]:587 apikey:yourSendGridApiKey

```
then perform the following
```
$ sudo chmod 600 /etc/postfix/sasl_passwd
$ sudo postmap /etc/postfix/sasl_passwd
$ sudo systemctl restart postfix
```

## Security checks
secure check that local mail server works only for localhost
```
$ sudo netstat -tulpn | grep :25
tcp        0      0 127.0.0.1:25            0.0.0.0:*               LISTEN      111740/master
tcp6       0      0 ::1:25                  :::*                    LISTEN      111740/master   
```

secure check that your firewall does not accept connections at mail server port
```
$ sudo ufw status
```

# Mail aliases
forward all email going to root and user01 (sudoer) to external mail
```
$ sudo vim /etc/aliases
postmaster:    root
root: admin@some-other-domain.com

$ sudo newaliases
$ sudo systemctl restart postfix && sudo postfix reload
```

# Troubleshoot
# Test sendgrid and DNS
This test does not cover postfix installation. This test covers if sendgrid and DNS zone are set correctly and can send an email using sendgrid API. According to sendgrid curl docs [6] edit and issue the following
```
curl --request POST \
  --url https://api.sendgrid.com/v3/mail/send \
  --header 'Authorization: Bearer YOUR_API_KEY' \
  --header 'Content-Type: application/json' \
  --data '{"personalizations": \
  	[{"to": [{"email": "recipient@somedomain.com"}]}], \
  	"from": {"email": "sendeexampexample@dimipet.com"}, \
  	"subject": "Hello, World!", \
  	"content": [{"type": "text/plain", "value": "Heya!"}]}'
```

delete `YOUR_API_KEY` above and place your API Key, it should look like this
```
--header 'Authorization: Bearer someWeirdoApiKeyOfMineWithManyCharacters'
```
## Test message
Send email using CLI to root. It should be relayed. You should receive this email under `admin@some-other-domain.com`.
```
$ echo "Testing my new postfix setup" | mail -s "Test email from `hostname`" root
```

## Logs
Check logs
```
$ tail -f /var/log/mail.log
```

Check if mail stick to queue. 1st mailq is for current user emails, second is for root's
```
$ mailq
$ sudo mailq
```

Check connectivity of localhost to sendgrid
```
$ telnet smtp.sendgrid.net 2525
```

# Notes about 127.0.0.1
The loopback range 127/8 is 127.0.0.0 - 127.255.255.255. All IPs in this range are bound to the loopback iface
according to ref [6]

```
The IP address 127.0.1.1 in the second line of this example may not be found on some other Unix-like 
systems. The Debian Installer creates this entry for a system without a permanent IP address as a 
workaround for some software (e.g., GNOME) as documented in the bug #719621. The host_name matches the 
hostname defined in the "/etc/hostname" (see Section 3.7.1, “The hostname”). For a system with a permanent 
IP address, that permanent IP address should be used here instead of 127.0.1.1. For a system with a 
permanent IP address and a fully qualified domain name (FQDN) provided by the Domain Name System (DNS), that canonical host_name.domain_name should be used instead of just host_name.
```

# References
[1]: https://www.debian.org/doc/manuals/debian-reference/ch05.en.html#_the_hostname_resolution
[2]: https://www.postfix.org/STANDARD_CONFIGURATION_README.html
[3]: https://www.unix.com/man-page/linux/5/mailname/
[4]: https://man7.org/linux/man-pages/man5/hostname.5.html
[5]: https://www.twilio.com/docs/sendgrid/ui/account-and-settings/how-to-set-up-domain-authentication
[6]: https://www.twilio.com/docs/sendgrid/for-developers/sending-email/curl-examples
[7]: https://www.postfix.org/postconf.5.html




