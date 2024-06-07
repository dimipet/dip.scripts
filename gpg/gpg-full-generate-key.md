```
$ gpg --full-generate-key 
gpg (GnuPG) 2.2.27; Copyright (C) 2021 Free Software Foundation, Inc. 
This is free software: you are free to change and redistribute it. 

There is NO WARRANTY, to the extent permitted by law. 
Please select what kind of key you want: 
   (1) RSA and RSA (default) 
   (2) DSA and Elgamal 
   (3) DSA (sign only) 
   (4) RSA (sign only) 
  (14) Existing key from card 
Your selection? 1 

RSA keys may be between 1024 and 4096 bits long. 
What keysize do you want? (3072) 4096 
Requested keysize is 4096 bits 

Please specify how long the key should be valid. 
         0 = key does not expire 
      <n>  = key expires in n days 
      <n>w = key expires in n weeks 
      <n>m = key expires in n months 
      <n>y = key expires in n years 
Key is valid for? (0) 0 
Key does not expire at all 
Is this correct? (y/N) y 

GnuPG needs to construct a user ID to identify your key. 
Real name: John Doe 
Email address: john.doe@example.com 
Comment:  
You selected this USER-ID: "John Doe <john.doe@example.com>" 
Change (N)ame, (C)omment, (E)mail or (O)kay/(Q)uit? O 

We need to generate a lot of random bytes. It is a good idea to perform 
some other action (type on the keyboard, move the mouse, utilize the 
disks) during the prime generation; this gives the random number 
generator a better chance to gain enough entropy. 
{...} 

gpg: key A2.....FF marked as ultimately trusted 
gpg: directory '/home/jd/.gnupg/openpgp-revocs.d' created 
gpg: revocation certificate stored as '/home/jd/.gnupg/openpgp-revocs.d/FG......rev' 

public and secret key created and signed. 

pub   rsa4096 2021-11-11 [SC] 
      FG...... 
uid   John Doe <john.doe@example.com> 
sub   rsa4096 2021-11-11 [E] 
```

