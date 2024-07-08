# Setup needed  
```
$ sudo apt install build-essential 
$ sudo apt install gcc git swig python3-dev libssl-dev pkg-config  
$ sudo apt install libavahi-client-dev avahi-daemon libtool autoconf automake make libsctp-dev libpam-dev libwrap0-dev  
$ sudo apt install libyaml-dev 
```

# Download gensio-2.2.4/ 
```
$ sudo ./configure  
$ sudo make 
$ sudo make install 
```

# Download cd ser2net-4.3.3/ 
```
$ sudo ./configure  
$ sudo make 
$ sudo make install 
$ sudo mkdir /etc/ser2net 
$ sudo cp ser2net.yaml /etc/ser2net/ 
$ sudo systemctl enable ser2net 
$ sudo systemctl start ser2net 
$ sudo systemctl status ser2net 
```
