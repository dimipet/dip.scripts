# argon2id syntax
password stored in `oc_users.password` field
```
3|$argon2id$v=19$m=65536,t=4,p=1$czFCSjk3LklVdXppZ2VCWA$li0NgdXe2/jwSRxgteGQPWlzJU0E0xdtfHbCbrpych0
```
lets break it down

- `$argon2id` : `argon2id` (variant used `argon2d`, `argon2i` or `argon2id`)
- `v=19` : version `19`
- `m=65536` : memory cost `65536`
- `t` : timing cost in linear iteration `4`
- `p=1` : parallelism `1`
- `salt` : base64-encoded salt `czFCSjk3LklVdXppZ2VCWA`
- `digest` : the base64-encoded hashed password (derived key), using standard base64-encoding and no padding `li0NgdXe2/jwSRxgteGQPWlzJU0E0xdtfHbCbrpych0`

Split with `$` 

- the last token is the digest 
- the one before is the salt

Prefix  

- in nextcloud `/lib/private/Security/Hasher.php` 
- the `public function hash(string $message): string` prefixes the hash 
    - with `3|` for `argon2id`
    - with `2|` for `argon2i`
    - with `1|` for `bcrypt`


# references
[1]: https://security.stackexchange.com/questions/222744/which-part-of-this-encoded-argon2-hash-is-the-salt

[1] https://security.stackexchange.com/questions/222744/which-part-of-this-encoded-argon2-hash-is-the-salt