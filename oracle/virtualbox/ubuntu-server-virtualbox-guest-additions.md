Start the VM -> Settings -> Storage -> choose optical drive -> 

choose `/home/dimipet/.config/VirtualBox/VBoxGuestAdditions_x.x.xx.iso`

open terminal and issue
```
$ sudo mount /dev/cdrom /media/cdrom && cd /media/cdrom
$ sudo apt-get install -y dkms build-essential linux-headers-generic linux-headers-$(uname -r)
$ sudo sh ./VBoxLinuxAdditions.run
```


