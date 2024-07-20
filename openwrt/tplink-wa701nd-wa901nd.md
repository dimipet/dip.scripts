
If your device has tplink firmware use openwrt factory image install  
If your device already has an older LEDE or OpenWrt firmware on it, refer to the sysupgrade howto instead.  

before you begin note down MAC address

# openwrt factory image install
- device has tplink firmware right now
- go to [https://openwrt.org/](https://openwrt.org/) 
- find device and specific version of device (ref.[1])
- download factory image / 
- download and keep backup of oem firmware stock
- go to device upgrade url function
- choose factory image
- upload 
- done
- go to 192.168.1.1 to setup router
- add passwords as suggested on top page / they are the same for ssh
- system - admin - ssh access - interface - choose lan - save+apply
- system - system - set hostname 
- system - system - set timezone - save+apply
- setup your access point

# sysupgrade install
- ...
- ...

# setup as access point aka bridged AP over ethernet
Use web configuration (ref.[2]), first setup wireless then ethernet

- go to 192.168.1.1
- network 
    - wireless 
    - enable SSID: OpenWrt 
    - press edit and configure it 
- network
    - interfaces - lan - edit 
    - protocol - dhcp client - switch protocol
    - physical settings - bridge interfaces - interface tick both (lan + wireless)
    - save and apply - wait 30 secs - apply unchecked - wait 30 - then ....
    - connect device to your main network 
    - find its ip (nmap / grep mac addr)
- system - reboot

# watchcat ping tool
install one by one 

- system - software - update lists (wait) - Download and install package - watchcat 
- system - software - update lists (wait) - Download and install package - luci-app-watchcat
- system - reboot
- services - watchcat - configure (ref.[3])
    - operating mode: reboot on internet connection lost
    - forced reboot delay: 1 (minutes: wait 1 mi before hard reboot)
    - period: 1 (minutes longest period of time to wait without internet access before reboot is engaged)
    - ping host: 1.1.1.1
    - ping period: 30 (seconds, how often to check)

# ssh problems
```
$ ssh root@192.168.1.1
Unable to negotiate with 192.168.1.1 port 22: no matching host key type found. Their offer: ssh-rsa
$ ssh -o HostKeyAlgorithms=+ssh-rsa -o PubkeyAcceptedAlgorithms=+ssh-rsa root@192.168.1.1
```

# references

[1] https://openwrt.org/toh/tp-link/tl-wa701nd  
[2] https://openwrt.org/docs/guide-user/network/wifi/wifiextenders/bridgedap  
[3] https://openwrt.org/docs/guide-user/advanced/watchcat  

[1]: https://openwrt.org/toh/tp-link/tl-wa701nd  
[2]: https://openwrt.org/docs/guide-user/network/wifi/wifiextenders/bridgedap
[3]: https://openwrt.org/docs/guide-user/advanced/watchcat
