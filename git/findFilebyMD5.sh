#!/bin/sh

# https://gist.github.com/pwolfram/73fdf5e2f7fae0f8eb8d2fb848f2ffc8
# Find file in git based on md5 checksum.

CHECKSUM=$1
FILE=$2

if [[ -z "$CHECKSUM" ]]; then
  echo "Usage: $0 md5 file"
  exit 1
elif [[ -z "$FILE" ]]; then
  echo "Usage: $0 md5 file"
  exit 1
fi

# Check if valid git repo
git status &> /dev/null

if [[ $? -ne 0 ]]; then
  echo "Not a valid git repo."
  exit 1
fi

# git revision for file
REVS=`git log --pretty=%H -- $FILE`

# check each revision for checksum
for rev in $REVS; do
  git show $rev:$FILE > _file_to_check
  # if you are on a Linux system, change md5 to md5sum
  if [[ -n `md5sum _file_to_check | grep $CHECKSUM` ]]; then
    echo $rev
  fi
  rm _file_to_check
done
