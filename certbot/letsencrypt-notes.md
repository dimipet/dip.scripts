
## letsencrypt certificates location and explanation
become `root` first
```
$ sudo -i
$ cd /etc/letsencrypt/live/www.dimipet.com

$ ls -la
lrwxrwxrwx ... cert.pem -> ../../archive/www.dimipet.com/cert1.pem
lrwxrwxrwx ... chain.pem -> ../../archive/www.dimipet.com/chain1.pem
lrwxrwxrwx ... fullchain.pem -> ../../archive/www.dimipet.com/fullchain1.pem
lrwxrwxrwx ... privkey.pem -> ../../archive/www.dimipet.com/privkey1.pem
-rw-r--r-- ... README
```
The above certificate files are

  * ascii base64 in `pem` format
  * ascii base64 since you can open them with text editor and see characters
  * not not binary (`der` format)

let's read the README file

```
$ cat README
    
    This directory contains your keys and certificates.
    
    `privkey.pem`  : the private key for your certificate.
    `fullchain.pem`: the certificate file used in most server software.
    `chain.pem`    : used for OCSP stapling in Nginx >=1.3.7.
    `cert.pem`     : will break many server configurations, and should not be used
                     without reading further documentation (see link below).
    
    WARNING: DO NOT MOVE OR RENAME THESE FILES!
             Certbot expects these files to remain in this location in order
             to function properly!
    
    We recommend not moving these files. For more information, see the Certbot
    User Guide at https://certbot.eff.org/docs/using.html#where-are-my-certificates.
```
apache uses
```
$ cat /etc/apache2/sites-enabled/www.dimipet.com-le-ssl.conf
...
SSLCertificateFile /etc/letsencrypt/live/www.dimipet.com/fullchain.pem
SSLCertificateKeyFile /etc/letsencrypt/live/www.dimipet.com/privkey.pem
```

## general pem file notes

- **.pem** may contain one of the following or both: 
    - one or more X.509 digital certificate in ascii base64 encoding and 
    - the private key. 
    - If it contains only a key then you can rename the file with `.key` extension
- **.key** ascii base64 encoding of a private key
- **.crt** contains one or more X.509 digital certificate in ascii base64 encoding
- **.ca-bundle** contains one or more X.509 digital certificate in ascii base64 encoding

