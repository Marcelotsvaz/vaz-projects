#
# VAZ Projects
#
#
# Author: Marcelo Tellier Sartori Vaz <marcelotsvaz@gmail.com>



# ECDSA with curve Curve25519
openssl genpkey -algorithm ED25519 -out domain.pem

# ECDSA with curve secp384r1
openssl genpkey -algorithm EC -pkeyopt ec_paramgen_curve:secp384r1 -out domain.pem

# RSA 2048 bits
openssl genpkey -algorithm RSA -pkeyopt rsa_keygen_bits:2048 -out domain.pem

# Public key
openssl pkey -pubout -in domain.pem -out domain.pem.pub

# Certificate Signing Request
openssl req -new -subj /CN=venditorepoa.com.br -key domain.pem -sha512 -out domain.csr

# Certificate Signing
dehydrated -f dehydrated.conf -p account.pem -s domain.csr --accept-terms > domain.crt

# Check
openssl pkey -text -noout -in domain.pem
openssl req -text -verify -noout -in domain.csr
openssl x509 -text -noout -in domain.crt


SSH:
	ssh-keygen -t ed25519 -N "" -C "VAZ Projects SSH Key" -f vazProjectsKey.pem
	# openssl genpkey -algorithm ED25519 -out ssh.pem
	# openssl pkey -pubout -in ssh.pem -out ssh.pem.pub
	
Account:
	openssl genpkey -algorithm RSA -pkeyopt rsa_keygen_bits:4096 -out accountKey.pem
	dehydrated -f dehydrated.conf -p accountKey.pem --register --accept-terms
	
Server:
	openssl genpkey -algorithm EC -pkeyopt ec_paramgen_curve:secp384r1 -out websiteKey.pem
	openssl req -new -subj / -addext 'subjectAltName = DNS:vazprojects.com, DNS:www.vazprojects.com' -key websiteKey.pem -sha512 -out websiteCsr.pem
	dehydrated -f dehydrated.conf -p accountKey.pem -s websiteCsr.pem --accept-terms > website.crt
	
CloudFront:
	openssl genpkey -algorithm RSA -pkeyopt rsa_keygen_bits:2048 -out cloudfrontKey.pem
	openssl req -new -subj /CN=static-files.vazprojects.com -key cloudfrontKey.pem -sha512 -out cloudfrontCsr.pem
	dehydrated -f dehydrated.conf -p accountKey.pem -s cloudfrontCsr.pem --accept-terms > cloudfront.crt