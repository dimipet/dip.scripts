#!/bin/bash

# when looping use IFS (internal field seperation) for space, tab, newline 

IFS=$'\n'

echo "Unstaged files : --------------------------------------------------------"
COMMAND=`git ls-files --others --exclude-standard`
for i in $COMMAND; do
	# echo item: $i $(md5sum) $i
	md5=`md5sum $i`
	echo ${md5}
done

echo "Staged files : ----------------------------------------------------------"
COMMAND=`git diff HEAD --name-only`
for i in $COMMAND; do
	# echo item: $i $(md5sum) $i
	md5=`md5sum $i`
	echo ${md5}
done
