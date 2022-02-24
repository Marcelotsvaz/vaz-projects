# 
# VAZ Projects
# 
# 
# Author: Marcelo Tellier Sartori Vaz <marcelotsvaz@gmail.com>



# ECDSA with curve Curve25519
openssl genpkey -algorithm ED25519 -out websiteKey.pem

# ECDSA with curve secp384r1
openssl genpkey -algorithm EC -pkeyopt ec_paramgen_curve:secp384r1 -out websiteKey.pem

# RSA 2048 bits
openssl genpkey -algorithm RSA -pkeyopt rsa_keygen_bits:2048 -out websiteKey.pem

# Public key
openssl pkey -pubout -in websiteKey.pem -out websiteKey.pem.pub

# Certificate Signing Request
openssl req -new -subj /CN=example.com -key websiteKey.pem -sha512 -out websiteCsr.pem
openssl req -new -subj / -addext "subjectAltName = DNS:example.com, DNS:www.example.com" -key websiteKey.pem -sha512 -out websiteCsr.pem

# Certificate Signing
dehydrated -f dehydrated.conf -p accountKey.pem -s websiteCsr.pem --accept-terms > website.crt

# Check
openssl pkey -text -noout -in websiteKey.pem
openssl req -text -verify -noout -in websiteCsr.pem
openssl x509 -text -noout -in website.crt