You get warnings e.g. for anydesk
```
$ sudo apt update
Reading package lists... Done
Building dependency tree... Done
Reading state information... Done
All packages are up to date.
W: http://deb.anydesk.com/dists/all/InRelease: Key is stored in legacy trusted.gpg keyring 
(/etc/apt/trusted.gpg), see the DEPRECATION section in apt-key(8) for details.
```
List your keys
```
$ sudo apt-key list
Warning: apt-key is deprecated. Manage keyring files in trusted.gpg.d instead (see apt-key(8)).
/etc/apt/trusted.gpg
--------------------
pub   rsa2048 2017-12-19 [SC] [expires: 2025-12-16]
      D563 11E5 FF3B 6F39 D5A1  6ABE 18DF 3741 CDFF DE29
uid           [ unknown] philandro Software GmbH <info@philandro.com>
sub   rsa2048 2017-12-19 [E] [expires: 2025-12-16]
```

Copy last 8 characters from 2nd line 
```
CDFF DE29
```

Export key, new file e.g. `anydesk.gpg` created under `trusted.gpg.d`
```
$ sudo apt-key export CDFFDE29 | sudo gpg --dearmour -o /etc/apt/trusted.gpg.d/anydesk.gpg
```

You are done, no more bugging
```
$ sudo apt update
Hit:1 http://deb.anydesk.com all InRelease
Get:2 http://security.ubuntu.com/ubuntu jammy-security InRelease [110 kB]
Hit:3 http://archive.ubuntu.com/ubuntu jammy InRelease
Hit:4 http://archive.ubuntu.com/ubuntu jammy-updates InRelease
Hit:5 http://archive.ubuntu.com/ubuntu jammy-backports InRelease
Fetched 110 kB in 1s (136 kB/s)
Reading package lists... Done
Building dependency tree... Done
Reading state information... Done
All packages are up to date.
```
