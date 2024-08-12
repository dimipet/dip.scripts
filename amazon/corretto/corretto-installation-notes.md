Install amazon corretto JDKs on debian-based linux

# apt repos based installation
```
$ wget -O - https://apt.corretto.aws/corretto.key | sudo gpg --dearmor -o /usr/share/keyrings/corretto-keyring.gpg && \
echo "deb [signed-by=/usr/share/keyrings/corretto-keyring.gpg] https://apt.corretto.aws stable main" | sudo tee /etc/apt/sources.list.d/corretto.list
```
install LTS JDKs (21, 17, 11, 8)
```
$ sudo apt-get update; sudo apt-get install -y java-21-amazon-corretto-jdk
$ sudo apt-get update; sudo apt-get install -y java-17-amazon-corretto-jdk
$ sudo apt-get update; sudo apt-get install -y java-11-amazon-corretto-jdk
$ sudo apt-get update; sudo apt-get install -y java-1.8.0-amazon-corretto
```

# dpkg based installation
first download from amazon website
```
$ sudo apt-get update && sudo apt-get install java-common
$ sudo dpkg --install java-11-amazon-corretto-jdk_11.0.23.9-1_amd64.deb
```
in case you need to uninstall 
```
$ sudo dpkg --remove java-11-amazon-corretto-jdk
```

# system wide JDK with alternatives
change the default java or javac providers
```
$ sudo update-alternatives --config java
$ sudo update-alternatives --config javac
```
# verify
```
$ java -version
$ javac -version
```



