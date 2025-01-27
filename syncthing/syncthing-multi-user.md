# Install syncthing for multiple users in Ubuntu using system service.

According to [https://docs.syncthing.net/users/autostart.html#linux](https://docs.syncthing.net/users/autostart.html#linux) , you have two primary options when installing syncthing: You can set up Syncthing

  * as a system service, or 
  * as a user service. 

Running Syncthing as a system service ensures that Syncthing is run at startup even if the Syncthing user has no active session. Since the system service keeps Syncthing running even without an active user session, it is intended to be used on a server. 

Running Syncthing as a user service ensures that Syncthing only starts after the user has logged into the system (e.g., via the graphical login screen, or ssh). Thus, the user service is intended to be used on a (multiuser) desktop computer. It avoids unnecessarily running Syncthing instances.

Goal here is the 1st option: install syncthing for each user and run it as system service.


## 1. Installation
Install syncthing first
```
$ echo "deb https://apt.syncthing.net/ syncthing stable" | sudo tee /etc/apt/sources.list.d/syncthing.list
$ curl -s https://syncthing.net/release-key.txt | sudo apt-key add -
$ sudo apt update
$ sudo apt install syncthing
```

Suppose we have 5 users in our linux system user1..user5. Enable syncthing service for every existing linux user. 
```
$ sudo systemctl enable syncthing@user1.service && sudo systemctl start syncthing@user1.service 
$ sudo systemctl enable syncthing@user2.service && sudo systemctl start syncthing@user2.service 
$ sudo systemctl enable syncthing@user3.service && sudo systemctl start syncthing@user3.service 
$ sudo systemctl enable syncthing@user4.service && sudo systemctl start syncthing@user4.service 
$ sudo systemctl enable syncthing@user5.service && sudo systemctl start syncthing@user5.service 
```

Note that we don't use user service (systemctl --user) but system wide service that will start at boot each time, regardless if the user has logged in.
```
$ sudo systemctl status syncthing@user*
● syncthing@user1.service - Syncthing - Open Source Continuous File Synchronization for user1
     Loaded: loaded (/lib/systemd/system/syncthing@.service; enabled; vendor preset: enabled)
     Active: active (running) since Sat 2024-01-20 17:09:47 EET; 48min ago
...
```
## 2. Configure GUI port
Now stop all syncthing instances and let's configure some stuff. 
```
$ for i in {1..5}; do sudo systemctl stop syncthing@user$i.service;done
```

Configure different GUI port for every user.
```
$ for i in {1..5}; do sudo -u user$i nano /home/user$i/.config/syncthing/config.xml
```
Change the following and make sure each user gets a different GUI port. I am posting an example only for user1
```
<gui enabled="true" tls="false" debugging="false">
        <address>127.0.0.1:8381</address>
```
You want to achieve the following
```
user1     <address>127.0.0.1:8381</address>
user2     <address>127.0.0.1:8382</address>
user3     <address>127.0.0.1:8383</address>
user4     <address>127.0.0.1:8384</address>
user5     <address>127.0.0.1:8385</address>
```

If you decide to start services one by one, you can also change GUI port by browser `https://127.0.0.1:8384/# --> Actions --> Settings --> GUI`

At this point we don't start any of the services. Move on to configure settings below.

## 3. Configure sync protocol listen address
According to documentation, <listenAddress> address:port is where a node receives TCP connections from other nodes (default: 0.0.0.0:22000). The port must be opened at the router, either through UPnP or port forwarding.

Make sure all syncthing instances are stopped and let's configure some stuff. 
```
$ for i in {1..5}; do sudo systemctl stop syncthing@user$i.service;done
```

Configure different listen address for every user.
```
$ for i in {1..5}; do sudo -u user$i nano /home/user$i/.config/syncthing/config.xml
```
Change the following and make sure each user gets a different listen address options. I am posting an example only for user1
```
    <options>
        <listenAddress>tcp://0.0.0.0:22001</listenAddress>
        <listenAddress>tcp://:22001</listenAddress>
        <listenAddress>quic://0.0.0.0:22001</listenAddress>
        <listenAddress>dynamic+https://relays.syncthing.net/endpoint</listenAddress>
```
You want to achieve the following
```
user1     tcp://0.0.0.0:22001, tcp://:22001, quic://0.0.0.0:22001, dynamic+https://relays.syncthing.net/endpoint
user2     tcp://0.0.0.0:22002, tcp://:22002, quic://0.0.0.0:22002, dynamic+https://relays.syncthing.net/endpoint
user3     tcp://0.0.0.0:22003, tcp://:22003, quic://0.0.0.0:22003, dynamic+https://relays.syncthing.net/endpoint
user4     tcp://0.0.0.0:22004, tcp://:22004, quic://0.0.0.0:22004, dynamic+https://relays.syncthing.net/endpoint
user5     tcp://0.0.0.0:22005, tcp://:22005, quic://0.0.0.0:22005, dynamic+https://relays.syncthing.net/endpoint

```
Now let your firewall accept these ports
```
$ for i in {1..5};do sudo ufw allow 2200$i/tcp && sudo ufw allow 2200$i/udp;done
```

Confirm your ufw firewall changes.
```
$ sudo ufw status verbose
```
         
If you decide to start services one by one, you can also change sync protocol listen addresses by browser `https://127.0.0.1:838x/# --> Actions --> Settings --> Connections --> Sync Protocol Listen Addresses`

At this point we don't start any of the services. Move on to configure settings below.
         
## 4. Configure discovery broadcasts (IPv4) and discovery multicasts (IPv6)
According to documentation, `localAnnouncePort` is the port on which to listen and send IPv4 broadcast announcements to. IPv4 UDP port used by a node to announce itself on the LAN, and also where it receives announcements from other nodes (default: 21025) for discovery broadcasts on IPv4. `localAnnounceMCAddr` is the group address and port to join and send IPv6 multicast announcements on. IPv6 broadcast address and UDP port used by a node to announce itself on the LAN; a node also receives IPv6 announcements from other nodes on this UDP port (default: [ff32::5222]:21026)for discovery multicasts on IPv6

Make sure all syncthing instances are stopped and let's configure some stuff. 
```
$ for i in {1..5}; do sudo systemctl stop syncthing@user$i.service;done
```

Configure different discovery broadcasts (IPv4) and discovery multicasts (IPv6) for every user.
```
$ for i in {1..5}; do sudo -u user$i nano /home/user$i/.config/syncthing/config.xml
```

Change the following and make sure each user gets a different discovery broadcasts (IPv4) and discovery multicasts (IPv6). I am posting an example only for user1 
```
        <globalAnnounceServer>default</globalAnnounceServer>
        <globalAnnounceEnabled>true</globalAnnounceEnabled>
        <localAnnounceEnabled>true</localAnnounceEnabled>
        <localAnnouncePort>21021</localAnnouncePort>
        <localAnnounceMCAddr>[ff12::8384]:21021</localAnnounceMCAddr>
```
         
You want to achieve the following
```
user1     localAnnouncePort 21021, localAnnounceMCAddr [ff12::8384]:21021
user2     localAnnouncePort 21022, localAnnounceMCAddr [ff12::8384]:21022
user3     localAnnouncePort 21023, localAnnounceMCAddr [ff12::8384]:21023
user4     localAnnouncePort 21024, localAnnounceMCAddr [ff12::8384]:21024
user5     localAnnouncePort 21025, localAnnounceMCAddr [ff12::8384]:21025
```
Now let your firewall accept these ports
```
$ for i in {1..5};do sudo ufw allow 2102$i/udp;done
```

Confirm your ufw firewall changes.
```
$ sudo ufw status verbose
```
         
If you decide to start services one by one, you can also these by browser `https://127.0.0.1:838x/# --> Actions --> Advanced --> Option`

## 5. Start services
Start each user's system service
```
$ for i in {1..5};do sudo systemctl start syncthing@user$i.service;done
```

Check what is running and how (user || service) is running
```
$ sudo systemctl status syncthing@*.service
$ for i in {1..5};do sudo systemctl show -pUser,UID syncthing@user"$i".service ; done
$ for i in {1..5};do sudo systemctl status syncthing@user"$i".service ; done
$ systemctl status --system
$ systemctl status --user
```

Show if all user gui is listening
```
$ netstat -natpe | grep 127.0.0.1:838
```

Show if all user listener is listening
```
$ netstat -natpe | grep 127.0.0.1:20
```

