#!/bin/bash

echo "simple util to check if all 7zip files within path supplied are valid"
echo
echo "7z-tester /path/to/my/7zip/files/"


for f in "$1"*.7z 
do
   if 7z t "$f" 2>&1 > /dev/null; then echo "$f" passed; else echo "$f" failed; fi
done
