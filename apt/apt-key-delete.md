Usually, you first install a repo's gpg key, then you add the repo to Ubuntu/Debian and then you install a package from this repo. 

However you may find a situation like the following.

```
dimipet@local:~$ sudo apt update
[sudo] password for dimipet: 

Warning: apt-key is deprecated. Manage keyring files in trusted.gpg.d instead (see apt-key(8)).

```

apt-key is using `/etc/apt/trusted.gpg` and keys are added in `/etc/apt/trusted.gpg.d`

lets delete e.g. docker key

list all keys, locate the key and copy last 8 chars

```
dimipet@local:~$ sudo apt-key list 

Warning: apt-key is deprecated. Manage keyring files in trusted.gpg.d instead (see apt-key(8)).
/etc/apt/trusted.gpg
--------------------
pub   rsa4096 2017-02-22 [SCEA]
      9DC8 5822 9FC7 DD38 854A  E2D8 8D81 803C 0EBF CD88
uid           [ unknown] Docker Release (CE deb) <docker@docker.com>
sub   rsa4096 2017-02-22 [S]
```

now lets delete the key

```
dimipet@local:~$ sudo apt-key del 0EBFCD88
```

dont forget to remove repo if needed from `/etc/apt/sources.list.d`
