## set remote origin
after clone locally your github created repo
```
$ git clone https://github.com/dimipet/my-repo.git                  $ clone locally
$ git config --local user.name "dimipet"                            # set github username
$ git config --local user.email "dimipet@dimipet.com"               # set email
$ git remote set-url origin git@github.com:dimipet/my-repo.git      # set remote
```

## remove remote origin
after deleting remote repo remove remote origin from local repo
```
$ git remote remove origin                                          # remove origin
```

## new branch and push to remote
```
$ git checkout -b devel                         # create and checkout new branch
$ git add pom.xml
$ git commit -m "initial pom"
$ git push --set-upstream origin devel          # just once
```

## clone private repository
using ssh
```
$ git clone git@github.com:dimipet/myrepo.git
```


