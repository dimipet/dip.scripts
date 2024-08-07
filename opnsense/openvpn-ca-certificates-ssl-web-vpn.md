# CA - Certification Authorites
Create 2 certification authorites

## 1st CA
System --> Trust --> Authorities -->  
- method: Create an internal Certificate Authority
- key: 4096 bits
- digest: SHA512
- lifetime: 3654 (10 years)
- country: Greece
- state: Macedonia
- organization: dimipet.com
- email: ca@dimipet.com
- cn: dimipet-ca

## 2nd intermediate CA - use with web gui
System --> Trust --> Authorities -->  
- method: Create an internal Certificate Authority
- key: 4096 bits
- digest: SHA512
- lifetime: 3654 (10 years)
- country: Greece
- state: Macedonia
- organization: dimipet.com
- email: ca@dimipet.com
- cn: dimipet-intermediate-ca

## web gui certificate
According to [[1]\]  
  
System --> Trust --> Certificates -->  

- method: Create an internal Certificate
- type: server
- descriptive name: Web GUI TLS certificate
- key: 2048 bits
- digest: SHA256
- lifetime: 1001
- country: Greece
- state: Macedonia
- organization: dimipet.com
- email: ca@dimipet.com
- cn: web.dimipet.local
- altenative names URI: https://web.dimipet.local

**WARNING:** cn has to be the same as `$ hostname -f`  
**WARNING:** set URI alternative name the same  

Then  
- System -> Settings -> Administrator -> set the web certificate to use 
- export intermediate CA certificate (i)
- open your browser and import it -> Preferences/Certificate/Authorities



## openvpn certificate
According to [[2]\]  
  
System --> Trust --> Certificates -->  

- method: Create an internal Certificate
- type: server
- descriptive name: SSLVPN Server Certificate
- key: 4096 bits
- digest: SHA512
- lifetime: 1001
- country: Greece
- state: Macedonia
- organization: dimipet.com
- email: ca@dimipet.com
- cn: vpn.certificate

If you have a ready running openvpn server/instance go ahead to set the certificate to use
- VPN --> OpenVPN --> Instances --> Edit
- certificate: SSLVPN Server Certificate
- save - restart

Now you can export new client config VPN --> OpenVPN --> ClientExport


# References
[1]: https://docs.opnsense.org/manual/how-tos/self-signed-chain.html
[2]: https://docs.opnsense.org/manual/how-tos/sslvpn_client.html

[1] https://docs.opnsense.org/manual/how-tos/self-signed-chain.html
[2] https://docs.opnsense.org/manual/how-tos/sslvpn_client.html