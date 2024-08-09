Response headers after initial install of apache2 are as follows:
```
$ curl --head http://localhost
HTTP/1.1 200 OK
Date: Thu, 11 Aug 2021 06:27:05 GMT
Server: Apache/2.1.11 (Debian)
Last-Modified: Thu, 11 Aug 2021 06:21:54 GMT
ETag: "aa-1111111113746"
Accept-Ranges: bytes
Content-Length: 110
Vary: Accept-Encoding
Content-Type: text/html
```
The above reveal info about OS and apache version.

Let's hide them: edit the following
```
$ sudo nano ./conf-enabled/security.conf
```

Change the following from
```
ServerTokens OS
ServerSignature On
```
to
```
ServerTokens Prod
ServerSignature Off
```

Restart apache and try curl again
```
$ sudo systemctl restart apache2.service
$ curl --head http://localhost
HTTP/1.1 200 OK
Date: Thu, 11 Aug 2021 06:27:05 GMT
Server: Apache
Last-Modified: Thu, 11 Aug 2021 06:21:54 GMT
ETag: "aa-1111111113746"
Accept-Ranges: bytes
Content-Length: 110
Vary: Accept-Encoding
Content-Type: text/html
```
