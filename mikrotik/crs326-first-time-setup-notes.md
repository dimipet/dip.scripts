# first setup - clear all
* connect http://192.168.88.1 / admin / no password OR
* connect using mac address OR
* connect using winbox OR
* connect using console
* reset keep no defaults (system->reset conf-> check no default conf)
* after that device won't be accessible with ip, use console setup

# console setup
* connect using RJ45 console cable + putty ( /dev/ttyUSB0, 115200, 8-N1, RTS/CTS ) \[[1]]
* find serial device with ` dmesg | grep tty` 
* press D within 2 secs of boot 
* menu -> boot -> choose routerOS
* once in terminal setup the following \[[2]]
```
/interface bridge add name=bridge1
/interface bridge port add interface=ether1 bridge=bridge1
/interface bridge port add interface=ether2 bridge=bridge1
/interface bridge port add interface=ether3 bridge=bridge1
/interface bridge port add interface=ether4 bridge=bridge1
/interface bridge port add interface=ether5 bridge=bridge1
/interface bridge port add interface=ether6 bridge=bridge1
/interface bridge port add interface=ether7 bridge=bridge1
/interface bridge port add interface=ether8 bridge=bridge1
/interface bridge port add interface=ether9 bridge=bridge1
/interface bridge port add interface=ether10 bridge=bridge1
/interface bridge port add interface=ether11 bridge=bridge1
/interface bridge port add interface=ether12 bridge=bridge1
/interface bridge port add interface=ether13 bridge=bridge1
/interface bridge port add interface=ether14 bridge=bridge1
/interface bridge port add interface=ether15 bridge=bridge1
/interface bridge port add interface=ether16 bridge=bridge1
/interface bridge port add interface=ether17 bridge=bridge1
/interface bridge port add interface=ether18 bridge=bridge1
/interface bridge port add interface=ether19 bridge=bridge1
/interface bridge port add interface=ether20 bridge=bridge1
/interface bridge port add interface=ether21 bridge=bridge1
/interface bridge port add interface=ether22 bridge=bridge1
/interface bridge port add interface=ether23 bridge=bridge1
/interface bridge port add interface=ether24 bridge=bridge1
/ip address add address=172.16.10.4/16 interface=bridge1

/ip dns set servers=1.1.1.1,8.8.8.8

/ip route add disabled=no dst-address=0.0.0.0/0 gateway=172.16.10.1

/interface/bridge/enable bridge1

/ip service set telnet disabled=yes
/ip service set ftp disabled=yes

/system note set show-at-login=no

/system ntp client set enabled=yes

/system ntp client servers
add address=0.gr.pool.ntp.org
add address=1.gr.pool.ntp.org
add address=2.gr.pool.ntp.org
add address=3.gr.pool.ntp.org

```
setup your pc ip in 172.16.10.0/16 and use http or winbox to complete installation


# references
[1]: https://help.mikrotik.com/docs/display/ROS/Serial+Console#SerialConsole-SerialTerminalUsage
[2]: https://help.mikrotik.com/docs/display/ROS/First+Time+Configuration

[1] https://help.mikrotik.com/docs/display/ROS/Serial+Console#SerialConsole-SerialTerminalUsage  
[2] https://help.mikrotik.com/docs/display/ROS/First+Time+Configuration