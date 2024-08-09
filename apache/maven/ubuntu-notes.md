# ubuntu alternatives
```
sudo update-alternatives --config mvn
```

# global conf file
```
$ sudo vim /usr/share/maven/conf/settings.xml
```

# configuration precedence
```
$ mvn -X clean package 
(...)
[DEBUG] Reading global settings from /usr/share/maven/conf/settings.xml
[DEBUG] Reading user settings from /home/dimipet/.m2/settings.xml
[DEBUG] Reading global toolchains from /usr/share/maven/conf/toolchains.xml
[DEBUG] Reading user toolchains from /home/dimipet/.m2/toolchains.xml
[DEBUG] Using local repository at /home/dimipet/.m2/repository

```
