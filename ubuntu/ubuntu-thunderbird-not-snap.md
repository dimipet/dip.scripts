On Ubuntu 24 thunderbird is snapped.  


# backup profile, emails, settings, etc
1. start TB
2. Help -> Troubleshooting information
3. Find "Profile Directory" and click open
4. go up two levels
5. close TB
5. backup (usually ~/.thunderbird)

# install deb TB
first remove snap TB and then install mozilla ppa version.  

```
$ sudo snap remove --purge thunderbird && sudo apt remove thunderbird 
$ sudo add-apt-repository ppa:mozillateam/ppa
```

set repo prioroties
```
$ sudo vim /etc/apt/preferences.d/mozillateamppa
Package: thunderbird*
Pin: release o=LP-PPA-mozillateam
Pin-Priority: 1001
```

now install
```
$ sudo apt update && sudo apt install thunderbird
```

disable unattended upgrades as TB snap may magically reappear
```
echo 'Unattended-Upgrade::Allowed-Origins:: "LP-PPA-mozillateam:${distro_codename}";' | sudo tee /etc/apt/apt.conf.d/51unattended-upgrades-thunderbird
```

# install snap TB
first remove deb TB
```
$ sudo apt remove thunderbird
```

set repo prioroties
```
$ sudo vim /etc/apt/preferences.d/mozillateamppa
Package: thunderbird*
Pin: release o=Ubuntu
Pin-Priority: -1
```

now install
```
$ sudo apt update && sudo apt install thunderbird
```


# references
[1] https://www.omgubuntu.co.uk/2024/08/install-thunderbird-deb-not-snap-in-ubuntu-24-04