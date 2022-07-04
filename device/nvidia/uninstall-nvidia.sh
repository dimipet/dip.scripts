#!/bin/bash

printf "bring zBook in usable xorg/nvidia state\n\n"

printf "\$XDG_SESSION_TYPE="$XDG_SESSION_TYPE"\n"
printf "\$DESKTOP_SESSION="$DESKTOP_SESSION"\n"

printf "\n# show driver in use\n"
lspci -nnk | grep -iA2 vga 


# show hardware
printf "\n# lshw -C display\n"
lshw -C display

printf "\n# dkms status\n"
# show dkms
dkms status

printf "\n# apt remove + purge nvidia*\n"
apt-get remove --purge '^nvidia-.*'

printf "\n# check install ubuntu-desktop\n"
apt-get install ubuntu-desktop


printf "\n# check if nouveau is in /etc/modules, if not append it\n"
is_nouveau_in_modules=0
while IFS= read -r line; do
  if [ "$line" == "nouveau" ]; then
    # found,  dont add it
    is_nouveau_in_modules=1
    break
  fi
done < /etc/modules

if [ $is_nouveau_in_modules -eq 0 ]; then echo 'nouveau' | tee -a /etc/modules ; fi;

printf "\n# rm /etc/X11/xorg.conf\n"
rm /etc/X11/xorg.conf
