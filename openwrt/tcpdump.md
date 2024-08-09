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