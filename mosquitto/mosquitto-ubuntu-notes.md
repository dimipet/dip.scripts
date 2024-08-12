# installation
```
$ sudo apt install mosquitto mosquitto-clients
$ sudo systemctl start mosquitto
$ sudo systemctl enable mosquitto
```


# QoS notes from mosquitto.org
```
Messages in MQTT are published on topics. There is no need to configure a topic, publishing on it is enough. 

QoS Levels

0: The broker/client will deliver the message once, with no confirmation (default)
1: The broker/client will deliver the message at least once, with confirmation required.
2: The broker/client will deliver the message exactly once by using a four step handshake.

Messages may be sent at any QoS level, and clients may attempt to subscribe to topics at any QoS level.This means that the client chooses the maximum QoS it will receive. For example, if a message is published at QoS 2 and a client is subscribed with QoS 0, the message will be delivered to that client with QoS 0. If a second client is also subscribed to the same topic, but with QoS 2, then it will receive the same message but with QoS 2. For a second example, if a client is subscribed with QoS 2 and a message is published on QoS 0, the client will receive it on QoS 0.
```
# test (with QoS 0)
open 1st shell
```
$ mosquitto_sub -t "garage/lights"
```

open 2nd shell
```
$ mosquitto_pub -m "ON" -t "garage/lights"
$ mosquitto_pub -m "OFF" -t "garage/lights"
```

shell 1 will receive messages

# secure connections
Add passwords to each mqtt device connection
```
$ sudo vim /etc/mosquitto/conf.d/default.conf
allow_anonymous false
password_file /etc/mosquitto/passwd

$ sudo touch /etc/mosquitto/passwd
$ sudo vim /etc/mosquitto/passwd
user01:my-secure-password-1
user02:my-secure-password-2
```

encrypt passwords in file
```
$ sudo mosquitto_passwd -U /etc/mosquitto/passwd
$ sudo systemctl restart mosquitto
```

# test with passwords (with QoS 0)
open 1st shell
```
$ mosquitto_sub -u user01 -P my-secure-password -t "garage/lights"
```

open 2nd shell
```
$ mosquitto_pub -u user02 -P my-secure-password -m "ON" -t "garage/lights"
$ mosquitto_pub -u user02 -P my-secure-password -m "OFF" -t "garage/lights"
```

# examples

## publisher QoS 2 / subscriber QoS 1
```
$ mosquitto_sub -u user01 -P user01 -t "garage/lights" -q 1
$ mosquitto_pub -u user02 -P user02 -m "ON" -t "garage/lights" -q 2
```

# logging
```
$ sudo tail -f /var/log/mosquitto/mosquitto.log
```

