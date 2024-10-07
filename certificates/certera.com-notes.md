# Certera registration
fill + registration details (email, name, password, tel, city, state)

# CPAC Pro - Comodo Personal Authentication Certificate Pro  

1. go to [https://certera.com/smime/comodo-personal-authentication-certificate](https://certera.com/smime/comodo-personal-authentication-certificate)
2. add to cart eg. 1 year
3. billing details 
4. pay
5. new page -> press enroll now
6. will head to Order Process [https://certera.com/dashboard/cpacorderprocess?odid=xxxxxxx](https://certera.com/dashboard/cpacorderprocess?odid=xxxxxxx) showing
    1. Product Name: Personal Authentication Pro Certificate
    2. TransactionID: XXX1234567VVV123456
    3. Purchase Date: 01-May-2024 (UTC)  
7. **Create CSR** using their online tool [https://certera.com/ssl-tools/csr-generator](https://certera.com/ssl-tools/csr-generator)
    1. hostname: dimipet@dimipet.com / your organizational email
    2. hostname: this is the common name (CN) and you want it to be an email 
    3. hostname: the email that you want your certificate for  
    4. hostname: email must use you own domain 
    5. hostname: no gmail outlook / you wont be able to sign
    6. org: dimipet.com (or dimipet) - name of you organization
    7. region: My Great City (fill your city name)
    8. country: Greece
    9. RSA 4096
    10. Generate now
    10. **BE SURE to save copy of CSR** text file output (BEGIN CERTIFICATE REQUEST...) 
    11. **BE SURE to download private key**
8. Return to Order Process and paste CSR
9. Fill in Requester Contact Info (Mr, name, surname, email the same used as hostname, tel) 
10. Agree and submit
11. Receive email (the one you used in hostname) and verify owner of this email
12. Get your certicate from certera.com/dashboard (actually they have problems to download and cert files are corrupt, ask in chat to direct you)

# Thunderbird & LibreOffice
To use it in thunderbird, libre office you need to convert the files in PFX format and import it so you can sign documents + send signed emails

To convert into PFX file, you will need 

1. the Certificate file (download it from certera), 
2. the Private key file (you downloaded it during CSR) 
3. the Intermediate certificate (bundle.crt) file which you ask through ticket/chat from certera

## 1st convertion method
You can use `$ openssl pkcs12 -export -out certificate.pfx -inkey private.key -in certificate.crt -certfile cacert.crt` and provide an export password  

## 2nd convertion method
Method proposed by certera is to **convert the cert to pfx using sslshopper.com**

- Use this tool: [https://www.sslshopper.com/ssl-converter.html](https://www.sslshopper.com/ssl-converter.html)
- Type of Current Certificate 'Standard PEM'
- Type To Convert To 'PFX/PKCS#12'
- Add Certificate File to Convert 
- Add the 'Private Key'
- Chain Certificate File - Add 'bundle.crt'
- Leave Chain Certificate File 2 blank
- Set a new 'PFX Password'
- Click on 'Convert Certificate'

## Import in Thunderbird

1. Edit -> Settings -> Privacy & Security -> Certificates
2. click Manage Certificates
3. Import pfx file

## Use in LibreOffice

1. Tools -> Options -> 
2. Libre Office -> Security
3. Certificate Path -> Certificate -> select Thunderbird:default
4. Restart 
5. Create new file and save it
5. File -> Digital Signatures -> Digital Signatures
6. Sign document -> enter Thunderbird's password -> Select certificate
7. (Optional) Write a description
8. Sign -> Top bar will popup say "this document is signed and signature valid"
9. If you save again signature is lost


# if anything goes wrong
If you already paid and something of the above goes wrong you will need to start process again

1. raise cancellation [https://certera.com/dashboard/cancellation?odid=xxxx](https://certera.com/dashboard/cancellation?odid=xxxx) (where xxxx your order no)
2. place a new order using the store credit and start the process from the beginning.
3. Select the cancelation reason as : I want to upgrade the certificate.
4. Repeat the steps above



