# linux client - vpn service auto-connect (deprecated)   

**warning** deprecated [[3]\] for openvpn version >= 2.6
> openvpn@.service is deprecated.  
> openvpn.service is obsoleted. (This is only used for backward compatibility)  
> Use the openvpn-client@.service like so:  
> $ sudo systemctl start openvpn-client@{Client-config}

verify - create accordingly
```
$ ls -la /etc/systemd/system/multi-user.target.wants/openvpn*
openvpn.service -> /lib/systemd/system/openvpn.service 
openvpn@my.service -> /lib/systemd/system/openvpn@.service 
```
if `my.service` not exists create it with the command below and paste following content
```
$ sudo systemctl status openvpn@my.service
```

```
$ cat /etc/systemd/system/multi-user.target.wants/openvpn.service  
[Unit] 
Description=OpenVPN service 
After=network.target 

[Service] 
Type=oneshot 
RemainAfterExit=yes 
ExecStart=/bin/true 
WorkingDirectory=/etc/openvpn 

[Install] 
WantedBy=multi-user.target 

$ cat /etc/systemd/system/multi-user.target.wants/openvpn@my.service  

[Unit] 
Description=OpenVPN connection to %i 
PartOf=openvpn.service 
Before=systemd-user-sessions.service 
After=network-online.target 
Wants=network-online.target 
Documentation=man:openvpn(8) 
Documentation=https://community.openvpn.net/openvpn/wiki/Openvpn24ManPage 
Documentation=https://community.openvpn.net/openvpn/wiki/HOWTO 

[Service] 
Type=notify 
PrivateTmp=true 
WorkingDirectory=/etc/openvpn 
ExecStart=/usr/sbin/openvpn --daemon ovpn-%i --status /run/openvpn/%i.status 10 --cd /etc/openvpn --script-security 2 --config /etc/openvpn/client/%i.conf --writepid /run/openvpn/%i.pid 
PIDFile=/run/openvpn/%i.pid 
KillMode=process 
CapabilityBoundingSet=CAP_IPC_LOCK CAP_NET_ADMIN CAP_NET_BIND_SERVICE CAP_NET_RAW CAP_SETGID CAP_SETUID CAP_SYS_CHROOT CAP_DAC_OVERRIDE CAP_AUDIT_WRITE 
LimitNPROC=100 
DeviceAllow=/dev/null rw 
DeviceAllow=/dev/net/tun rw 
ProtectSystem=true 
ProtectHome=true 
RestartSec=5s 
Restart=on-failure 
 
[Install] 
WantedBy=multi-user.target 

$ sudo systemctl enable openvpn@my.service 
$ sudo systemctl start openvpn@my.service 
``` 

 

**CAUTION : The Line above  **

```
ExecStart=/usr/sbin/openvpn --daemon ovpn-%i --status /run/openvpn/%i.status 10 --cd /etc/openvpn --script-security 2 --config /etc/openvpn/client/%i.conf --writepid /run/openvpn/%i.pid 
```
consists of the `--config /etc/openvpn/client/%i.conf `  

That means that any *.conf file left in `/etc/openvpn/client/` will be run by the service


# references
[1]: https://openvpn.net/community-resources/reference-manual-for-openvpn-2-6/
[2]: https://docs.opnsense.org/manual/vpnet.html#openvpn-ssl-vpn
[3]: https://community.openvpn.net/openvpn/wiki/Systemd

[1] https://openvpn.net/community-resources/reference-manual-for-openvpn-2-6/  
[2] https://docs.opnsense.org/manual/vpnet.html#openvpn-ssl-vpn  
[3] https://community.openvpn.net/openvpn/wiki/Systemd  
