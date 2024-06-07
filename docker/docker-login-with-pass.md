usual way
```
$ pass init <your-key-id> 
$ docker logout 
$ docker login 
```
troubleshoot
```
$ systemctl --user stop docker-desktop.service 
$ cd ~/.docker/ 
$ rm ./config.json* 
$ rm -rf ~/.password-store/ 
$ systemctl --user restart docker-desktop.service 
$ pass init <your-key-id> 
$ docker logout 
$ docker login 
$ systemctl --user restart docker-desktop.service 
```

