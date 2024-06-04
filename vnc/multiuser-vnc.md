Suppose you have 15 users that need to have a remote desktop to work (e.g. in a classroom).  
You need a vnc server to do that.  

# install

using simple lubuntu "server",  install the following

```
$ sudo apt install xfonts-base xfonts-75dpi xfonts-100dpi xorg lxde-core lxterminal 
$ sudo apt install tightvncserver
```

assign a vnc password for your user
```
$ vncpasswd
Using password file /home/dimipet/.vnc/passwd
Password:
Verify:   
Would you like to enter a view-only password (y/n)? n
```

```
$ sudo nano /home/$(whoami)/.vnc/xstartup
unset SESSION_MANAGER
unset DBUS_SESSION_BUS_ADDRESS
xrdb $HOME/.Xresources
xsetroot -solid grey
export XKL_XMODMAP_DISABLE=1

#openbox &
#/usr/bin/lxsession -s Lubuntu &
# Error:
# main.vala:103 DE is (null)
# main.vala:113 No desktop environment set, fallback to LXDE
# Xlib: extension "RANDR" missing on display :1
# main.vala.134: log directory /home/username/.cache/lxsession/Lubuntu
# main.vala.135: log path: /home/username/.cache/lxsession/Lubuntu/run.log
  
# Requires: sudo apt install xfce4 xfce4-goodies
# As of 5/23/20, the packages above are incomplete
#startxfce4 &
  
# Use the light version of desktop environment
# Requires: sudo apt install xorg lxde-core
lxterminal &
/usr/bin/lxsession -s LXDE &
```

open firewall ports, you probably need more that 15 as each time a user starts his own vmcserver instance will use one port. If some processes die you need more ports to accomodate.  
```
$ sudo ufw allow 5900:5920/tcp
```

deploy copy this to all users you want 
probably you want to for-loop it but this is the idea
```
USR=user01 && sudo cp /home/dimipet/.vnc/xstartup /home/$USR/.vnc/xstartup
USR=user01 && sudo touch /home/$USR/.Xresources && sudo chown $USR:$USR /home/$USR/.Xresources

USR=user02 && sudo cp /home/dimipet/.vnc/xstartup /home/$USR/.vnc/xstartup
USR=user02 && sudo touch /home/$USR/.Xresources && sudo chown $USR:$USR /home/$USR/.Xresources

```

# start, connect, stop
each user must 
1. ssh 
2. create his password
3. start his own server  
```
$ ssh user01@host

user01@host:~$ vncpasswd
Using password file /home/user01/.vnc/passwd
Password:
Verify:
Would you like to enter a view-only password (y/n)? n
user01@host:~$ vncserver 

New 'X' desktop is host:1
```
server assigned some port to the user  
it said `host:1`, that means he should use port `5901`  

user should now start his vnc client of choice and connect as `user01@host:5901` with the password he created  


to stop server, user should 
```
user@host:~$ vncserver -kill :1
```

if you want to see all vnc instances, connections
```
$ sudo netstat -peanut | grep "vnc"
tcp        0      0 0.0.0.0:6001            0.0.0.0:*               LISTEN      1001       48380      3648/Xtightvnc      
tcp        0      0 0.0.0.0:5901            0.0.0.0:*               LISTEN      1001       48382      3648/Xtightvnc      
tcp        0      0 192.168.41.33:5901      192.168.41.30:34928     ESTABLISHED 1001       44674      3648/Xtightvnc
tcp        0      0 192.168.41.33:5902      192.168.41.32:12325     ESTABLISHED 1001       44684      3648/Xtightvnc 
```

