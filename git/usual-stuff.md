--------------------------------------------------

| Working   | Staging    |   Local   |   Remote  |
| directory | Index Area |   Repo    |   Repo    |

--------------------------------------------------

# Help

```
$ git help <command> 
$ git status –help     # Show the possible options for the status command in command line 
$ git help --all     # Show all git possible commands in command line
```

# Initialize repo

```
$ git init 
```

# Local settings

stored in `.git/config`

```
$ git config --local 
$ git config --local user.name "dimipet" 
$ git config --local user.email "email@example.com" 
```

# System wide settings

stored in `~/.gitconfig` 

```
$ git config --global  
$ git config --global user.name "dimipet" 
$ git config --global user.email "email@example.com" 
```

# Proxy settings

```
$ git config --local http.proxy http://my-proxy-ip-domain:80  
$ git config --local https.proxy https://my-proxy-ip-domain:80 
$ git config --global http.proxy http://my-proxy-ip-domain:80  
$ git config --global https.proxy https://my-proxy-ip-domain:80
```

# Add

```
$ git add -A         # Stage all new, modified, and deleted files
```

# Move/Rename

## Move/Rename/Undo within git (preferred)

renames and moves within git and within OS 

```
$ git mv file1.txt fileA.txt     # not permanently renamed yet 
$ git commit ...         # permanently renamed 
```

undoing before commit

```
$ git mv file1.txt fileA.txt
$ git mv fileA.txt file1.txt     # undo before commit 
$ git status             # everything will be clear / nothing to commit 
```

## Move/Rename from OS

```
$ mv file1.txt fileA.txt 
$ ls –la         # will show the rename 
$ git status         # git status will show 2 actions (1) deleted old files and (2) added new file with same contents 
$ git add –A         # add changes and also add any files updated moved deleted. *CAREFULL: will add any file to stage index * 
$ git status         # now git knows the rename  
$ git commit -m ...     # finalize the rename 
$ git status         # all clear 
```

* If you don’t want to add any file then just add one-by-one manually
  
  ```
  $ git add fileA.txt  
  ```

# Delete tracked files

## Delete within git (preferred)

deletes within git and within OS 

```
$ git rm fileA.txt
$ git status        # staged for deletion, not permanently deleted yet 
$ git commit -m ...    # commit deletion permanently deleted
```

undo delete before commit

```
$ git reset HEAD fileA.txt    # remove before commit deletion within git 
$ git status            # will report that file is deleted 
$ git checkout -- fileA.txt    # recovers file 
$ git status            # everything clear 
```

## Delete from OS

delete a file with OS commands

```
$ rm fileA.txt 
$ ls –la        # confirms file deletion from os 
$ git status        # git status will show deleted file not staged for commit 
$ git add –A        # add any files updated moved deleted. CAREFULL: will add any file to stage index * 
$ git status        # git knows/staged the delete 
$ git commit -m ...    # finalize deletion 
$ git status        # all clear 
```

delete a folder with OS commands

```
$ rm –rf ./dir 
$ ls –la        # confirm folder deletion from os 
$ git status        # git status will show all deleted folders and files not staged for commit 
$ git add –A        # add any files updated moved deleted. CAREFULL: will add any file to stage index * 
$ git status        # git knows/staged the deletions 
$ git commit -m ...    # finalize deletion,  
$ git status         # all clear 
```

*If you don’t want to add any file the just add one-by-one manually 

```
$ git add ./dir
```

# History log

using `git log`

```
$ git help log 
$ git log --oneline --decorate --all --graph
$ git log                # chronological with SHA1 
$ git log --abbrev-commit        # sha-1 shortened 
$ git log d6f7g89...g2h3j4k        # from commit to commit 
$ git log --since="3 days ago"        # since 3 days ago
$ git log -- fileA.txt            # show for specific file 
$ git log --follow -- dirA/fileA.txt     # show for specific file and follow renames 
```

using `git show`

```
$ git show                 # show content committed last commit 
$ git show k6j5h43             # show content committed commit 
```

```
(master) $ git log            # shows log only from the current branch
(master) $ git log --branches=*        # show log from every/all branches
```

# Alias

```
$ git config --global alias.hist "log --all --oneline --graph –decorate" # anything start with alias becomes alias 
$ git hist 
$ nano ~/.gitconfig # check all aliases 
```

# Ignores

```
$ cd /path/to/git/project 
$ touch .gitignore 
$ nano .gitignore 
$ git add .gitignore 
$ git commit ... 
$ git status # all clear 
```

# Diff

## diff between 3 stages of git: working, stage and local repo

`diff` & `difftool` can be used interchangeably 
Compare local working directory with stage index area e.g.: modified fileA, added fileA to stage, re-modified fileA 

```
$ git diff 
```

Compare local working with local repo =  
Compare local working with HEAD =  
Compare local working with last commit on current branch  

```
$ git diff HEAD 
```

Compare staged with local repo =  
Compare local working with HEAD =  
Compare staged with last commit on current branch  

```
$ git diff --staged HEAD 
```

Compare specific file/folder, not everything 

```
$ git diff <revision> <path>
$ git diff b0d14a4 fileA
git diff master~5:pom.xml master:pom.xml # diff master branch current file to master 5 revisions ago
```

## diff with commits, local repo only

```
$ git log --oneline         # Check which commits to compare 
$ git diff 5c05047 HEAD     # see all changes from all files from last commit to specific commit 
$ git diff HEAD HEAD^         # see all changes from all files from last commit to previous 
$ git diff 5c05047 789ade4     # see all changes from all files between 2 commits (i.e. ) 
```

## diff between branches (local/remote)

```
$ git diff master origin/master # diff local master branch and remote master branch  
```

# Repos & branches

## some terms

`master` used to be the default name for branches
`main` is the default name for branches

`origin` is a link representing {any|the|a} remote repo that the project was cloned from  
`origin main` means = remote repo, `main` branch  
`origin master` refers to the name of the remote repo, `master` is the remote branch  

`origin/main` is a local copy of `origin master`  
`origin/main` is not a pointer to `origin master`  
`origin/main` gets updated when you `git fetch origin main` or `git pull`  
`origin/main` represents the state of the remote repo  

upstream branch = the remote branch   
upstream branch = the branch you fetch/pull with `git fetch` `git pull` without arguments

## local branches

```
$ git branch             # list local only branches, * starred is the current 
$ git branch –a            # list all local/remote branches
$ git branch -d somebranch     # delete branch
$ git branch -m old new     # rename branch from old to new
$ git checkout -b title        # create and switch to branch one line
$ git branch mynew         # 2-step create new branch and ...
$ git checkout mynew        # ... switch to it
$ git log --oneline --decorate    # check how it looks in history
                # `6e58a4d`  is our last commit, local `HEAD` points to mynew
                # `origin/HEAD` points to remote branch
                # All these branch labels point to the same commit
6e58a4d (HEAD -> mynewbranch, origin/master, origin/HEAD, master) update repo with changes from compare section 
```

## remote branches

```
$ git remote show origin    # shows fetch/push URL, HEAD branch name, remote tracked branches, branch configured for 'git pull' & 'git push'
$ git pull origin master    # fetches changes (commits) from the remote repo branch and integrate (merge) them into the local checked out branch
$ git push origin master    # push changes to the master branch of remote repo
$ git pull            # shorthand for `git pull origin master`, works only if current checked out branch is tracking an upstream branch
$ git push            # shorthand for `git push origin master`, works only if current checked out branch is tracking an upstream branch
```

## set pull upstream branches

`git pull` and `git push` works only if current checked out branch is tracking an upstream branch.

```
$ git push -u origin master                # run once, set the upstream branch for master when using `git push` w/o arguments
$ git push --set-upstream origin master            # same as previous, run once, set upstream branch when using `git push` w/o arguments
$ git push                        # now you can push w/o arguments
```

## set push upstream branches

```
$ git branch --set-upstream-to=origin/master master    # set the upstream branch for master when using `git pull` w/o arguments
$ git pull                        # now you can pull w/o arguments
```

### push local branch to remote

```
$ git switch -c new2            # create
$ git branch -a                # confirm
$ git push --set-upstream origin new2    # push, --set-upstream needs to run only once
```

### delete local and remote branch

```
$ git branch --merged            # check that branch is already merged
$ git branch -d initial_app        # deleted branch initial_app
$ git push -d origin initial_app    # deleted remote branch
```

### rename local branch and push to remote

//TODO

# Merge

## merged vs nont merged branches

```
$ git branch --merged            # show branches that are already merged
$ git branch –no-merged            # show branches that not yet merged
```

## fast forward merge / ff-merge

Fast forward = even if you branch in e.g. new-branch and make 100 commits, when you change back to you master branch and merge, all these commits will appear in history as commits of master branch – if you try to read which commits where made from in the new-branch it is impossible to see them. 

Fast forward = git places all the commits in the current branch as if we never branched away
Fast forward can only happen when there are no changes in target branch 

After a ff-merge history is as follows 
`o---o---o---o---o`

### ff-merge workflow

```
(master) $ git checkout -b titles        # create and switch to new branch
(titles) $ git nano ... save/exit        # add/edit files
(titles) $ git commit -am "Changing title"    # commit and see log
(titles) $ git log --oneline –decorate        # see history log
(titles) $ git checkout master            # return to main branch, 
(master) $ git diff master titles        # diff to see changes
(master) $ git merge titles            # merge the branch to the current
(master) $ git log --oneline --decorate --graph    # show that both branches point to same commit id
0aef36f (HEAD -> master, title) Changing title 
(master) $ git branch -d titles            # we can delete branch
(master) $ git log --oneline --decorate --graph    # deleted branch is not shown anymore
0aef36f (HEAD -> master) Changing title
```

## non fast forward merge / non-ff-merge

Merge w/o ff = called merge commit  
Merge w/o ff = when a new commit has 2 parents  

e.g. master and feature branch get merged in a new commit where it has parents:  

1. last commit of feature branch and  
2. last commit of master branch  

On a non-ff-merge, the commits show up in history in the branch where they were made  
After a non-ff-merge history is like follows  

```
...../----o-----o--\ 
o---o---o---o---o---o 
```

### non-ff-merge workflow

```
(master) $ git checkout -b copyright            # create new branch
(copyright) $ nano simple.html                # edit 1 file and commit
(copyright) $ git commit -am "add copyright"        # edit one more file and new commit 
(copyright) $ nano README.md                # edit one more file
(copyright) $ git commit -am "add more copyright"     # commit
(copyright) $ git log --oneline --graph –decorate    # check: We have 2 commits that are part of this branch
(copyright) $ git checkout master            # go to master branch and merge
```

Be careful, this time we branched off, this is no fast forward  
So we have to turn off fast forward  

```
(master) $ git merge copyright --no-ff        # accept the merge message as is
(master) $ git log --oneline --graph –decorate    # check: we will see the branching with the name of the branch
(master) $ git branch -d copyright        # delete the branch
```

Check: we will see the branching with out the name of the branch  
Branching off is shown but with out label  

```
$ git log --oneline --graph –decorate 
```

## automatic merge

automatic merge = merge commit automatically  

### automatic merge workflow

switch to branch simple make changes there and commit them  
switch to master, don't merge yet  BUT make changes and commit them  
merge new-branch in master  

```
(master) $ git checkout -b simple        # switch to branch simple-changes
(simple) $ nano humans.txt             # make changes 
(simple) $ git commit -am "adding team member"    # commit changes
(simple) $ git checkout master            # switch to master
(master) $ nano README.md            # don't merge yet BUT make changes
(master) $ git commit -am "adding info "    # commit changes 
(master) $ git log --oneline --graph --decorate # show log
(master) $ git merge simple -m ....        # merge commit from simple branch
(master) $ git log --oneline --graph --decorate # will show how we branched off 
(master) $ git branch -d simple-changes        # delete branch 
(master) $ git log --oneline --graph --decorate    # show log
```

## Merge conflicts with mergetool or p4merge

Suppose you have 2 branches, and in each branch the same file gets changed in the same lines  
When you try to merge it will conflict  
Use some tool to resolve conflict  

```
(master) $ git checkout -b realwork            # do changes in one branch 
(realwork) $ nano simple.html                 # make changes in specific lines 
(realwork) $ git commit -am "making changes" 
(realwork) $ git checkout master             # Go to the master braqnch and ...
(master) $ nano simple.html                 # do changes again in same file in specific lines 
(master) $ git add simple.html              
(master) $ git commit -m "..."                # commit
(master) $ git diff master realwork            # diff between branches
(master) $ git difftool master realwork            # diff again using difftool
(master) $ git merge realwork                # try to merge, you get conflict
Auto-merging simple.html 
CONFLICT (content): Merge conflict in simple.html 
Automatic merge failed; fix conflicts and then commit the result.    
```

Now you are in an area to resolve conflict, you get out of this area when you resolve conflicts and commit

```
$ nano simple.html  

<<<<<<< 

======= 

>>>>>>> 
```

Everything between <<<<<<< and ======= are your local changes.  
These changes are not in the 2nd branch / remote repository yet.  
All the lines between ======= and >>>>>>> are the changes from the remote repository or another branch.  
Use a tool 3 way compare to resolve and then commit: `mergetool` or `p4merge`  

Use mergetool

```
$ git mergetool  
$ git commit -m "done resolving merge conflict conflicts" 
```

or use p4merge as it keeps original conflicted file *.orig in case something goes wrong 

```
$ git status 
$ nano simple.html.orig  
$ nano .gitignore                    # Ignore *.orig files
$ git status 
$ git add .gitignore                    # Commit .gitignore
$ git commit -am "updating gitignore orig text files" 
$ git log --oneline --graph –decorate            # check graph log
$ git branch -d realwork                # delete branch
$ git log --oneline --graph –decorate
```

## Abort/Undo merge

You should always keep in mind that you can return to the state before you started the merge at any time.  
This should give you the confidence that you can't break anything.  
When you are in the merging area (I.e. bash prompt MERGING) on the command line type this and it will do this for you. 

```
$ git merge –abort 
```

In case you've made a mistake while resolving a conflict and realize this only after completing the merge, you can still easily undo it: just roll back to the commit before the merge happened with `git reset --hard` and start over again. 

# Stash

```
$ git stash        # stash tracked files
$ git stash -u        # stash tracked and untracked files
$ git stash list    # show all stashes
$ git stash pop        # 1-step Unstash using last stash then drop 
$ git stash clear    # delete all stashed
```

2-step Unstash using last stash then drop

```
$ git stash apply    # unstash
$ git stash drop    # drop
```

Add a message to stash. List them with their message 

```
$ nano index.html 
$ git stash save "index.html some stash commit message" 
$ nano simple.html 
$ git stash save "simple.html some stash commit message" 
$ nano README.md 
$ git stash save "readme some stash commit message" 
$ git stash list 
```

CAUTION: stash is a stack, when listing  
{0} is the last stash,  
{2} is the first / oldest  
Always 0 is the last.  
Each time you add a stash each member in the stash changes index  

Show a stash, it will list which files are part of the stash and statistics of diff  

```
$ git stash show stash@{1} 

Index.html | 2 +- 
1 file changed, 1 insertion(+), 1 deletion(-) 
```

2-step apply and drop specific stash 

```
$ git stash apply stash@{1} 
$ git stash drop stash@{1} 
```

## stash workflow with branches

Suppose you are in master abd you have  

* staged files (modified and added),  
* unstaged files (modified files but added yet)  
* untracked files  

Stash everything, move to a new branch, then pop the stash there (I.e. apply the stash there then drop the stash)  

```
(master) $ git stash –u 
(master) $ git stash branch newchanges 
Switched to a new branch 'newchanges' 
On branch newchanges 
Changes to be committed: … 
Changes not staged for commit: … 
Untracked files: … 
Dropped refs/stash@{0} …. 
```

Then as usual merge/drop branch 

```
(newchanges) $ git add ... 
(newchanges) $ git commit -am ...
(newchanges) $ git checkout master  
(master) $ git merge newchanges ...    # fast forward merge 
(master) $ git branch –d newchanges    # cleanup
(master) $ git pull
(master) $ git push origin master 
```

# Tags

## lightweight tags

create lightweight tag from current commit, see/confirm it, then delete it

```
(master) $ git tag myTag                # create for current commit 
(master) $ git log --oneline --graph --decorate --all    # see it
* a99c7ab (HEAD -> master, tag: myTag, origin/master, origin/HEAD) local: update simple.html copyright notice 
* c056937 remote: minor change to index.html 
(master) $ git tag --list                # see all tags / careful 2 dash otherwise it will create new tag named -list
MyTag 
(master) $ git show myTag                # see info of commit using myTag
(master) $ git tag --delete myTag            # delete it
Deleted tag 'myTag' (was a99c7ab) 
(master) $ git tag --list                # check that it disappeared from tag list 
(master) $ git log --oneline --graph --decorate --all    # check that it disappeared from log
* a99c7ab (HEAD -> master, origin/master, origin/HEAD) local: update simple.html copyright notice 
* c056937 remote: minor change to index.html 
```

## annotated tags

same as a lightweight tag, except it has a little extra information.  
It usually has what's equivalent to a commit message, but for tags. 

```
(master) $ git tag -a v-0.1                # create tag
(master) $ git tag --list                # show all tags
(master) $ git log --oneline --graph --decorate --all    # confirm tag in log
(master) $ git show v-0.1                # will show all as lightweight but with commit message, commiter, diff, +++ etc
```

## tag comparing

Lets edit some files and add many tags and then compare

```
(master) $ nano index.html
(master) $ git commit –a        
(master) $ git tag -a v-1.1 
(master) $ nano simple.html 
(master) $ git commit –a 
(master) $ git tag -a v-1.2 
(master) $ git tag --list
(master) $ git diff v-0.1 v-1.2
```

## tag previous/older commit

```
(master) $ git tag --list
(master) $ git log --oneline --graph --decorate --all    # check log
(master) $ git tag -a v-0.9-beta 0aef36f         # pick old commit and tag it
(master) $ git log --oneline --graph --decorate --all    # check log, confirm tag
(master) $ git tag -a v-0.8-beta 6e58a4d        # pick old commit and tag it
(master) $ git log --oneline --graph --decorate –all    # check log, confirm tags
```

## tag rename lightweight/annotated + push remote repo

pick old tag and change it and push it 

```
(master) $ git tag --list
(master) $ git log --oneline --graph --decorate –all 
(master) $ git tag v-1.0 v-0.1 
(master) $ git tag -d v-0.1 
(master) $ git push origin new :v-0.1 
```

The colon in the push command removes the tag from the remote repository. If you don't do this, Git will create the old tag on your machine when you pull. Finally, make sure that the other users remove the deleted tag. Please tell them (co-workers) to run the following command: 

```
(master) $ git pull --prune --tags 
```

Note that if you are changing an annotated tag, you need ensure that the new tag name is referencing the underlying commit and not the old annotated tag object that you're about to delete. Therefore, use git tag -a new old^{} instead of git tag new old (this is because annotated tags are objects while lightweight tags are not, more info in this answer). 

## push tag to remote repo

create tag for specific commit and with specific message and push it to remote repo

```
$ git tag -a v0.31 3d4fe9b -m "version 0.31"        # create tag for commit id 3d4fe9b with -m message
$ git push origin v0.31                    # push it
```

## tag update

pick a tag and change the commit it is connected to 

```
(master) $ git tag --list  
(master) $ git log --oneline --graph --decorate –all 
```

there's a couple of approaches  

1. delete and recreate tag on specific commit  
2. do the same by forcing an update with -f  
   Using the 2nd approach  
   
   ```
   (master) $ git tag -a v-0.8-beta -f ea95872 
   Updated tag 'v-0.8-beta' (was 6cbd74e) 
   (master) $ git log --oneline --graph --decorate –all 
   ```
   
   ## tags in github
   
   They don’t get pushed automatically, so to commit specific
   ```
   (master) $ git tag --list  
   (master) $ git log --oneline --graph --decorate –all 
   (master) $ git push origin v-0.8-beta             
   Enumerating objects: 1, done. 
   Counting objects: 100% (1/1), done. 
   Writing objects: 100% (1/1), 164 bytes | 164.00 KiB/s, done. 
   Total 1 (delta 0), reused 0 (delta 0) 
   To github.com:dimipet/starter-web.git 
* [new tag]         v-0.8-beta -> v-0.8-beta 
  
  ```
  to commit all, then check them in releases/tags
  ```
  
  (master) $ git push origin master –tags
  Enumerating objects: 3, done. 
  Counting objects: 100% (3/3), done. 
  Delta compression using up to 8 threads 
  Compressing objects: 100% (3/3), done. 
  Writing objects: 100% (3/3), 419 bytes | 419.00 KiB/s, done. 
  Total 3 (delta 0), reused 0 (delta 0) 
  To github.com:dimipet/starter-web.git 
* [new tag]         v-1.0 -> v-1.0 
* [new tag]         v-1.1 -> v-1.1 
* [new tag]         v-1.2 -> v-1.2 
  
  ```
  to delete one from github remote repo but keep it locally
  ```
  
  (master) $ git push origin :v-0.8-beta
  To github.com:dimipet/starter-web.git 
- [deleted]         v-0.8-beta 
  
  ```
  
  ```

# References

1. https://www.udemy.com/course/git-complete/  
2. Linux diff command summary with examples https://www.youtube.com/watch?v=f1jNBpn07VM  
3. https://git-scm.com/book/en/v2/Git-Branching-Branches-in-a-Nutshell  
4. https://www.git-tower.com/learn/git/ebook/en/command-line/advanced-topics/merge-conflicts  
5. https://www.atlassian.com/git/tutorials/merging-vs-rebasing  
6. https://www.atlassian.com/git/tutorials/syncing/git-fetch  
7. https://www.geeksforgeeks.org/git-difference-between-git-fetch-and-git-pull/  
8. https://stackoverflow.com/questions/1028649/how-do-you-rename-a-git-tag  
9. https://www.atlassian.com/git/tutorials/rewriting-history/git-reflog  
10. https://www.atlassian.com/git/tutorials/undoing-changes/git-reset  
11. https://www.atlassian.com/git/tutorials/resetting-checking-out-and-reverting  
12. https://www.w3schools.com/git/git_revert.asp?remote=github  
