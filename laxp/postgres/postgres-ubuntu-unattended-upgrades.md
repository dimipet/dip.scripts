postgres dies with the following errors after ubuntu `unattended-upgrade` installs an pgdg upgrade

web
```
Internal Server Error

The server encountered an internal error and was unable to complete your request.
Please contact the server administrator if this error reappears multiple times, please include the technical details below in your report.
More details can be found in the server log.
```

cron mails
```
Failed to connect to the database: An exception occurred in the driver: SQLSTATE[08006] [7] connection to server at (...) , port (.....) failed: Connection refused
	Is the server running on that host and accepting TCP/IP connections?
```

# solutions proposed

## check repos and policies
usual case is mixed pgdg and ubuntu postgres repos
```
$ grep -h ^deb /etc/apt/sources.list /etc/apt/sources.list.d/*

$ apt policy postgresql-14
postgresql-14:
  Installed: 14.13-0ubuntu0.22.04.1
  Candidate: 14.13-0ubuntu0.22.04.1
  Version table:
 *** 14.13-0ubuntu0.22.04.1 500
        500 http://gr.archive.ubuntu.com/ubuntu jammy-updates/main amd64 Packages
        500 http://security.ubuntu.com/ubuntu jammy-security/main amd64 Packages
        100 /var/lib/dpkg/status
     14.2-1ubuntu1 500
        500 http://gr.archive.ubuntu.com/ubuntu jammy/main amd64 Packages

$ apt policy postgresql-15
N: Unable to locate package postgresql-15

$ apt policy postgresql-16
N: Unable to locate package postgresql-16


```

## solution: manual unattended-upgrades
if you are good with this remove blacklisted
```
$ sudo unattended-upgrade -d
```

## solution: blacklist
according to [[1]\] and especially [[2]\]

```
$ vim /etc/apt/apt.conf.d/50unattended-upgrades
Unattended-Upgrade::Package-Blacklist {
        "postgresql-*";
        "libpq5";
        "pgbackrest";
        "python3-psycopg2";
};
```

# references
[1]: https://www.postgresql.org/message-id/CAHJZqBBzix3%3D9dP%3DkAiLi3Y-YGCJKb%3Dt6F%2B_L4D%2BSL7MxX8gtA%40mail.gmail.com
[2]: https://seiler.us/2020-11-18-unattended-upgrades/

[1] https://www.postgresql.org/message-id/CAHJZqBBzix3%3D9dP%3DkAiLi3Y-YGCJKb%3Dt6F%2B_L4D%2BSL7MxX8gtA%40mail.gmail.com
[1] https://seiler.us/2020-11-18-unattended-upgrades/