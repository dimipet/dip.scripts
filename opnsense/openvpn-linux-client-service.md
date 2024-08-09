# linux client - vpn

According to [[1]\]
>Note:
> openvpn@.service is deprecated.
> openvpn.service is obsoleted. (This is only used for backward compatibility)

new way to have client service is
```
$ sudo systemctl start openvpn-client@{Client-config}
```
check if your distro supports it

# references
[1]: https://community.openvpn.net/openvpn/wiki/Systemd
[2]: https://community.openvpn.net/openvpn/wiki/OpenVPN3Linux
[3]: https://community.openvpn.net/openvpn/wiki/OpenvpnSoftwareRepos#DebianUbuntu:UsingOpenVPNaptrepositories

[[1]\] https://community.openvpn.net/openvpn/wiki/Systemd  
[[2]\] https://community.openvpn.net/openvpn/wiki/OpenVPN3Linux  
[[3]\] https://community.openvpn.net/openvpn/wiki/OpenvpnSoftwareRepos#DebianUbuntu:UsingOpenVPNaptrepositories  
