# Install Amazon Corretto 11 on Debian-Based Linux

## apt repos
```
$ wget -O - https://apt.corretto.aws/corretto.key | sudo gpg --dearmor -o /usr/share/keyrings/corretto-keyring.gpg && \
echo "deb [signed-by=/usr/share/keyrings/corretto-keyring.gpg] https://apt.corretto.aws stable main" | sudo tee /etc/apt/sources.list.d/corretto.list
```
## install java-11
```
$ sudo apt-get update; sudo apt-get install -y java-11-amazon-corretto-jdk

```
## install java-17
```
$ sudo apt-get update; sudo apt-get install -y java-17-amazon-corretto-jdk

```

## install java-8
```
$ sudo apt-get update; sudo apt-get install -y java-1.8.0-amazon-corretto

```

## manual
```
$ sudo apt-get update && sudo apt-get install java-common
$ sudo dpkg --install java-11-amazon-corretto-jdk_11.0.23.9-1_amd64.deb
```

## verify
```
$ java -version
```

## alternatives
$ change the default java or javac providers
```
$ sudo update-alternatives --config java
$ sudo update-alternatives --config javac
```

## uninstall
```
$ sudo dpkg --remove java-11-amazon-corretto-jdk
```
