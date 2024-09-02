check if port is listening / port forwaring 

```
root@openwrt:~# tcpdump -pnvvi eth1.2 port 60044 
```

And from another client initiate something like  
```
ssh@ip_address –p60044 
```
 
Check if it is coming from specific src ip and going to specific dst port 
```
root@openwrt:~# tcpdump -pnvvi eth1.2 src 11.22.33.44 and dst port 1194 
```

> -n    Don't  convert  addresses  (i.e.,  host addresses, port numbers,
>              etc.) to names.
> 
> -i    interface
> 
> -p
> --no-promiscuous-mode
>       Don't  put  the  interface into promiscuous mode.  Note that the
>       interface might be in promiscuous mode for  some  other  reason   
>       `-p'  cannot be used as an abbreviation for ether host {local-hw-addr} 
>       or ether broadcast.


# references
[1]: https://boxmatrix.info/wiki/Property:nc
[2]: https://git.busybox.net/busybox/tree/

[1] https://boxmatrix.info/wiki/Property:nc
[2] https://git.busybox.net/busybox/tree/