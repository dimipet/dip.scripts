# openvpn conf options
options used, docs at [[1]\]


`--dev` *device*  
which TUN/TAP virtual network device to use  

- tun devices encapsulate IPv4 or IPv6 (OSI Layer 3)  
- tap devices encapsulate Ethernet 802.3 (OSI Layer 2).  
- ovpn is platform dependent name  
- openvpn uses physical (ethernet) and virtual interfaces to connect to the world.  
- openvpn uses one dedicated virtual interface to work e.g. `ovpns1`, `ovpns3` etc.
```
dev ovpns2
```

`--server` *args*	
A helper directive designed to simplify the configuration of OpenVPN's server mode. This directive will set up an OpenVPN server which will allocate addresses to clients out of the given network/netmask. The server itself will take the .1 address of the given network for use as the server-side endpoint of the local TUN/TAP interface. If the optional nopool flag is given, no dynamic IP address pool will prepared for VPN clients.

```
server 10.55.55.0 255.255.255.0`
```

`--client-to-client`  
Because the OpenVPN server mode handles multiple clients through a single tun or tap interface, it is effectively a router. The --client-to-client flag tells OpenVPN to internally route client-to-client traffic rather than pushing all client-originating traffic to the TUN/TAP interface.

`--client-config-dir` *dir*
Specify a directory dir for custom client config files. After a connecting client has been authenticated, OpenVPN will look in this directory for a file having the same name as the client's X509 common name. If a matching file exists, it will be opened and parsed for client-specific configuration options. If no matching file is found, OpenVPN will instead try to open and parse a default file called "DEFAULT", which may be provided but is not required. Note that the configuration files must be readable by the OpenVPN process after it has dropped it's root privileges.

This file can specify a fixed IP address for a given client using `--ifconfig-push`, as well as fixed subnets owned by the client using `--iroute`.

One of the useful properties of this option is that it allows client configuration files to be conveniently created, edited, or removed while the server is live, without needing to restart the server.

The following options are legal in a client-specific context: 
```
--push, --push-reset, --push-remove, --iroute, --ifconfig-push, --vlan-pvid and --config
```

```
client-config-dir /var/etc/openvpn-csc/2
```

`--push` *option*  
Push a config file option back to the client for remote execution   
partial list of options which can currently be pushed: 
```
--route, --route-gateway, --route-delay, --redirect-gateway, --ip-win32, 
--dhcp-option, --dns, --inactive, --ping, --ping-exit, --ping-restart, 
--setenv, --auth-token, --persist-key, --persist-tun, --echo, --comp-lzo, 
--socket-flags, --sndbuf, --rcvbuf, --session-timeout
```
```
push "route 192.168.1.0 255.255.255.0"
```

`--route` *args*	
Add route to routing table after connection is established. Multiple routes can be specified. Routes will be automatically torn down in reverse order prior to TUN/TAP device close.
```
route 172.16.1.0 255.255.0.0
```

`--persist-tun`  
Don't close and reopen TUN/TAP device or run up/down scripts across SIGUSR1 or --ping-restart restarts

`--persist-key`  
Don't re-read key files across SIGUSR1 or --ping-restart.

`--dev-type` *device-type*  
Which device type are we using? device-type should be tun (OSI Layer 3) or tap (OSI Layer 2). Use this option only if the TUN/TAP device used with `--dev` does not begin with tun or tap.
```
dev-type tun
```

`--proto` *p*	
Use protocol p for communicating with remote host. p can be udp, tcp-client, or tcp-server. You can also limit OpenVPN to use only IPv4 or only IPv6 by specifying p as udp4, tcp4-client, tcp4-server or udp6, tcp6-client, tcp6-server, respectively.
```
proto udp
```

`--verb` *n*	
Set output verbosity to n (default 1).
```
verb 3
```

`--port` *port*	 
TCP/UDP port number or port name for both local and remote (sets both --lport and --rport options to given port). The current default of 1194 represents the official IANA port number assignment for OpenVPN and has been used since version 2.0-beta17. Previous versions used port 5000 as the default.
```
port 1194
```

`--local` *host* 	
Local host name or IP address for bind. If specified, OpenVPN will bind to this address only. If unspecified, OpenVPN will bind to all interfaces.
```
local 10.0.0.21
```

`--auth` *alg*	
Authenticate data channel packets and (if enabled) tls-auth control channel packets with HMAC using message digest algorithm alg. (The default is SHA1 ). HMAC is a commonly used message authentication algorithm (MAC) that uses a data string, a secure hash algorithm and a key to produce a digital signature.
```
auth SHA512
```

`--tls-server`  
Enable TLS and assume server role during TLS handshake. Note that OpenVPN is designed as a peer-to-peer application. The designation of client or server is only for the purpose of negotiating the TLS control channel.


# references
[1]: https://openvpn.net/community-resources/reference-manual-for-openvpn-2-6/

[1] https://openvpn.net/community-resources/reference-manual-for-openvpn-2-6/
