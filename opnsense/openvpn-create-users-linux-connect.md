# VPN Server  
Setup your vpn server [[2]\] and note down your selections

First check and implement notes on CA, intermediate CA and certificates for openvpn and webgui

# Users
You have to create users first.   

1. If you have LDAP --> System: Access: Users --> import button --> choose ldap user --> check box --> save. Otherwise System: Access: Users --> add button  
2. System: Access: Users --> edit create the user -->  
    - if in LDAP --> Generate a scrambled password to (prevent local database logins for this user) 
    - otherwise add and note a username and strong password - you will need to use them below
    - add Full Name
    - add email
    - check create certificate
    - add info needed and save
    - then you will be redirected to user certifaces on which choose:
    - method: create intenal certificate
    - description: same as CN
    - type: client
    - location: save on this firewall
    - key type: RSA-4096 
    - Digest: SHA512 
    - lifetime: 825 
    - issuer: your main CA certicate
    - add country, state, city, organization, org.unit, 
    - add a real email, 
    - add a unique common name (CN)
    - save 
3. VPN: OpenVPN --> client Export
    - remote access server: my-openvpn-server-name 
    - export type: File Only 
    - hostname -> 1.2.3.4 (probably router static public IP or associated DNS with port-fwd 1194)  
    - check use random local port
    - check Validate server subject 
    - check Disable password save (this sets auth-nocache in the exported configuration when password authentication is used otherwise you get log warnings) 
    - then at bottom of page download click corresponding download of users account/certificate .ovpn file AND 
    - use it to import in openvpn client (android, linux, windows, mac) 


# Linux client 

## install
```
$ sudo apt install ... 
```

## linux client - upload ovpn file 

**Caution: don’t leave *.conf files in /etc/openvpn/client, they will all be run **

- scp upload your ovpn file to your linux client in `/etc/openvpn/client` 
- rename it to something meaningful e.g. `my-openvpn-connection.conf`
- `$ sudo mv my-openvpn-connection.conf /etc/openvpn/client`
- leave only your `my-openvpn-connection.conf` in `/etc/openvpn/client`


## linux client – password

**Caution: Make sure when exporting openvpn to Check -> Disable password save -> Sets auth-nocache in the exported configuration when password authentication is used  
**

```
$ sudo vim /etc/openvpn/client/OpenVPNpass.txt 
Username123 
mypassword123444 
$ sudo chmod 600 /etc/openvpn/client/OpenVPNpass.txt 
```
**make sure** that `auth-user-pass` in your vpn client `conf` file points to correct location
```
auth-user-pass /etc/openvpn/client/OpenVPNpass.txt
```
## linux client - check connection
```
$ openvpn --config /etc/openvpn/my-openvpn-connection.conf
```
check your logs

# references
[1]: https://openvpn.net/community-resources/reference-manual-for-openvpn-2-6/
[2]: https://docs.opnsense.org/manual/vpnet.html#openvpn-ssl-vpn
[3]: https://community.openvpn.net/openvpn/wiki/Systemd

[1] https://openvpn.net/community-resources/reference-manual-for-openvpn-2-6/  
[2] https://docs.opnsense.org/manual/vpnet.html#openvpn-ssl-vpn  
[3] https://community.openvpn.net/openvpn/wiki/Systemd  
