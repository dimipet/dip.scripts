# setup
```
$ sudo adduser tcl dialout 
$ sudo apt install setserial 
$ sudo dpkg-reconfigure setserial 
```

check if needed 
```
$ sudo nano /var/lib/setserial/autoserial.conf 
```
## dp by hand configuration 
```
/dev/ttyS0 uart 16550A port 0x03f8 irq 4 baud_base 9600 spd_normal skip_test 
#/dev/ttyS3 uart 16550A port 0x02e8 irq 3 baud_base 115200 spd_normal 
#/dev/ttyS3 baud_base 115200 auto_irq skip_test autoconfig spd_normal 
```
 
# install
```
$ sudo snap install ser2net-plars  
$ ser2net-plars.config-get > /tmp/ser2net.yaml  
```
# edit the config
CAUTION DONT USE TABS IN YAML ONLY SPACES 
```
$ cat /tmp/ser2net.yaml |sudo /snap/bin/ser2net-plars.config-set  
$ sudo snap restart ser2net-plars.ser2net 
```
# logging
```
$ tail –f /var/log/syslog 
```
