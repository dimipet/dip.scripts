# set remote
after clone locally your github created repo
```
$ git clone https://github.com/dimipet/my-repo.git                  $ clone locally
$ git config --local user.name "dimipet"                            # set github username
$ git config --local user.email "dimipet@dimipet.com"               # set email
$ git remote set-url origin git@github.com:dimipet/my-repo.git      # set remote
```

# new branch and push to remote
```
$ git checkout -b devel                         # create and checkout new branch
$ git add pom.xml
$ git commit -m "initial pom"
$ git push --set-upstream origin devel          # just once
```

