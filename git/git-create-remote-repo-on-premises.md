# git server
create a dump simple git server hosting a (remote) repo
``` 
$ git@server:~ $ mkdir -p /srv/git/project.git 
$ cd project.git 
$ git init --bare 
$ touch git-daemon-export-ok 
```

# git client
git clone locally
```
$ git clone git@192.168.0.3/project.git 
```

general notes on how to commit to remote repo 
```
$ git add . 
$ git commit -m "message" 
$ git pull
$ git push
```


