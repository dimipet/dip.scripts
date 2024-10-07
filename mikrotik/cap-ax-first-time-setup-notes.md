# first time setup
simple ap install with 
* all ifaces bridged
* with wifi wave

 1. connect cAP to LAN using eth2 port, fire up winbox, connect to it using mac address, reset conf of cAP keep no defaults (system->reset conf-> check no default conf) 
 2. connect again as in step 0, find architecture (system -> resources), download latest routeros 7 same arch, open winbox, drag drop routeros-7.10.2-arm64.npk, when uploaded reboot to start upgrade, dont power off. In case reboot takes too long (more than 15 minutes) reset it (power off + hold reset), connect again and check version
 3. connect again as in step 0, download routeros 7 packages of same arch, open winbox, upload wifiwave2-7.10.2-arm64.npk, (mandatory for ac/ax devices), reboot
 4. connect w/ winbox, when asked remove all configuration and don't use quick set / modes etc, conf should be done step by step (cli of gui)

```
/interface bridge
add name=bridge

/interface list
add name=management

/interface wifiwave2 security
add authentication-types=wpa2-psk,wpa3-psk disabled=no name=sec1

/interface wifiwave2
set [ find default-name=wifi1 ] channel.band=5ghz-ax .skip-dfs-channels=all \
    .width=20/40/80mhz configuration.country=Greece .mode=ap .ssid=dimipet-5.0 \
    disabled=no security=sec1 security.wps=disable

set [ find default-name=wifi2 ] channel.band=2ghz-ax .skip-dfs-channels=all \
    .width=20/40mhz configuration.country=Greece .mode=ap .ssid=dimipet-2.4 \
    disabled=no security=sec1 security.wps=disable

/interface bridge port
add bridge=bridge interface=ether1
add bridge=bridge interface=ether2
add bridge=bridge interface=wifi1
add bridge=bridge interface=wifi2

/ip neighbor discovery-settings
set discover-interface-list=management

/interface list member
add interface=bridge list=management

/ip address
add address=172.16.10.8/24 interface=bridge network=172.16.10.1

/ip dns
set servers=1.1.1.1,8.8.8.8

/ip route
add disabled=no dst-address=0.0.0.0/0 gateway=172.16.10.1

/ip service
set telnet disabled=yes
set ftp disabled=yes

/system note
set show-at-login=no

/system ntp client
set enabled=yes

/system ntp client servers
add address=0.gr.pool.ntp.org
add address=1.gr.pool.ntp.org
add address=2.gr.pool.ntp.org
add address=3.gr.pool.ntp.org

/tool mac-server mac-winbox
set allowed-interface-list=management
```

# references 
[1] https://forum.mikrotik.com/viewtopic.php?t=186178

