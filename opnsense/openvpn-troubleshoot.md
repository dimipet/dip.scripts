# show net interfaces
```
$ ifconfig
```

# tcpdump if vpn is passing
```
$ tcpdump -pnvvi hn0 port 1194 
$ tcpdump -pnvvi hn0 port 1194 | grep '11.12.13.14'      # coming from specific ip
$ tcpdump -pnvvi hn0 src 11.22.33.44 and dst port 1194   # coming from specific src ip and going to specific dst port

```