# X.509 certificate formats

Certificates come in 2 flavors: ascii and binary.  
You can use a a text editor to open a certificate file.   
If regular characters appear then it is base64 ascii.   
Otherwise it is a binary file.


## Base64 (ASCII)
###PEM

- **.pem** may contain one of the following or both: 
    - one or more X.509 digital certificate in ascii base64 encoding and 
    - the private key. 
    - If it contains only a key then you can rename the file with `.key` extension
- **.key** ascii base64 encoding of a private key
- **.crt** contains one or more X.509 digital certificate in ascii base64 encoding
- **.ca-bundle** contains one or more X.509 digital certificate in ascii base64 encoding

###PKCS#7

- **.p7b**
- **.p7s**

## Binary

###DER
- **.der** contains one or more X.509 digital certificate in binary format + no private key
- **.cer** contains one or more X.509 digital certificate in binary format + no private key

###PKCS#12
- **.pfx** contains one or more X.509 digital certificate in binary format + private key (protected by password)
- **.p12** contains one or more X.509 digital certificate in binary format + private key (protected by password)

# example
## apache vhost configuration
```
Include /etc/letsencrypt/options-ssl-apache.conf
SSLCertificateFile /etc/letsencrypt/live/vm01.dimipet.com/fullchain.pem
SSLCertificateKeyFile /etc/letsencrypt/live/vm01.dimipet.com/privkey.pem
```
`privkey.pem`  : the private key for your certificate.  
`fullchain.pem`: the certificate file used in most server software.

## comodo certera personal certificate
`dimipet.com.key`: the private key for your certificate  
`dimipet.com.crt`: your certificate  
`cacert-bundle`: the intermediate certificate.  


# convert .crt cetificate file to .pfx
you need
- the certificate in crt format `certificate.crt`
- the ca certificate (bundle) `cacert.crt`
- the private key `private.key`
```
$ openssl pkcs12 -export -out certificate.pfx -inkey private.key -in certificate.crt -certfile cacert.crt
```






