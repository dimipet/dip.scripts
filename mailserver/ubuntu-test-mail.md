# send test mails

# send to myself user@dimipet-host1 and read
```
user@dimipet-host1:~$ echo "this is a test mail" | mail -s "Subject line" user@dimipet-host1
user@dimipet-host1:~$ mail
"/var/mail/user": 1 message 1 new
>N   1 user             Fri Jun   11/111   Subject line
? 1
Return-Path: <user@dimipet-host1>
X-Original-To: user@dimipet-host1
Delivered-To: user@dimipet-host1
Received: by dimipet-host1 (Postfix, from userid 1000)
	id 123465F111; Fri,  7 Jun 2024 13:04:04 +0300 (EEST)
Subject: Subject line
To: <user@dimipet-host1>
User-Agent: mail (GNU Mailutils 3.19)
Date: Fri,  7 Jun 2024 13:04:04 +0300
Message-Id: <20240607090304.123465FE111@dimipet-host1>
From: user <user@dimipet-host1>

this is a test mail
```

# user send to root@localhost and read mail as root

```
user@dimipet-host1:~$ echo "this is a test mail" | mail -s "Subject line" root@localhost
$ sudo mail
[sudo] password for user: 
"/var/mail/root": 1 message 1 new
>N   1 mail             Fri Jun   11/111   Subject line
? 1
Return-Path: <user@dimipet-host1>
X-Original-To: root@localhost
Delivered-To: root@localhost
Received: by dimipet-host1 (Postfix, from userid 1000)
	id 123B35F123; Fri,  7 Jun 2024 12:03:04 +0300 (EEST)
Subject: Subject line
To: <root@localhost>
User-Agent: mail (GNU Mailutils 3.19)
Date: Fri,  7 Jun 2024 12:03:04 +0300
Message-Id: <20240607090304.123B35F123@dimipet-host1>
From: ubuntu <user@dimipet-host1>

this is a test mail

```

# see outgoing queue
```
$ mailq
```

