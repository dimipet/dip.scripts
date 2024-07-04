# contents
```
$ cat file1.txt
cat
lazy
dog
bark

$ cat file2.txt
cat
lazy
bark
dog

```
# context format 
lets diff
```
$ diff -c file1.txt file2.txt 
*** file1.txt	2024-06-19 09:31:59.789140258 +0300
--- file2.txt	2024-06-19 09:32:47.090987312 +0300
***************
*** 1,4 ****
  cat
  lazy
- dog
  bark
--- 1,5 ----
  cat
  lazy
  bark
+ dog
+ 
```

explanation  

`***` 1st file  
`---` 2nd file  
`*** file1.txt` info about 1st file: filename, modification date and time  
`--- file2.txt` info about 2nd file: filename, modification date and time  
`***************` separator  

indicators of each line:
`  ` (two spaces) line is unchanged on both files  
`+ ` line in 2nd file to be added to the 1st file for identical files  
`- ` line in 1st file to be deleted for identical files  

in our example these mean:
`*** 1,4 ****`	1st file / line range 1-4  
`  cat `	unchanged on both files
`  lazy`	unchanged on both files
`- dog `	remove this line from 1st file to promote identical files
`  bark`	unchanged on both files

`--- 1,5 ---*`	2nd file / line range 1-5  
`  cat`		unchanged on both files
`  lazy`	unchanged on both files
`  bark`	unchanged on both files
`+ dog`		add this line to 1st file to promote identical files
`+ `		add this (empty) line to 1st file to promote identical files

# unified format
```
$ diff -u file1.txt file2.txt
--- file1.txt	2024-06-19 09:51:43.101749176 +0300
+++ file2.txt	2024-06-19 09:32:47.090987312 +0300
@@ -1,4 +1,5 @@
 cat
 lazy
-dog
 bark
+dog
+
```
explanation  

`***` 1st file  
`---` 2nd file  
`*** file1.txt` info about 1st file: filename, modification date and time  
`--- file2.txt` info about 2nd file: filename, modification date and time  

indicators of each line:
` ` (one space) line is unchanged on both files  
`+` line in 2nd file to be added to the 1st file for identical files  
`-` line in 1st file to be deleted for identical files  

`@@ -1,4 +1,5 @@`	range for both files: `-1,4` range for 1st, `+1,4` range for 2nd  
` cat`			unchanged on both files
` lazy`			unchanged on both files
`-dog`			remove this line from 1st file to promote identical files
` bark`			unchanged on both files
`+dog`			add this line to 1st file to promote identical files
`+`			add this (empty) line to 1st file to promote identical files





examples [3]

[1]: https://www.gnu.org/software/diffutils/manual/html_node/Detailed-Unified.html
[2]: https://www.gnu.org/software/diffutils/manual/html_node/Detailed-Context.html
[3]: https://www.geeksforgeeks.org/diff-command-linux-examples/
