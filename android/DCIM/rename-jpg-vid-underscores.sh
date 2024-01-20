#!/bin/bash

# remove leading IMG_
for f in IMG_*.jpg; do 
  mv "$f" "$(echo "$f" | sed s/IMG_//)"; 
done

# remove leading VID
for f in VID_*.mp4; do
  mv "$f" "$(echo "$f" | sed s/VID_//)";
done

# replace _ with space
for f in *_*.*; do
  mv "$f" "$(echo "$f" | sed s/_/\ /)";
  #echo "$f"
done

