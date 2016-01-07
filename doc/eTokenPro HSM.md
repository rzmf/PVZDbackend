# HSM with Gemalto/SafeNet/Alladin eToken Pro
http://www.safenet-inc.de/data-protection/authentication/etoken-pro/

The eToken Pro is a USB-format smartcard.  Attached to an internal USB connector 
on the machine hosting the pyFF instance signatures can be created on the HSM 
via a PKCS#11 interface, thus not exposing the private key to the server.

The machine running pyFF need to have the etoken driver
libraries installed. The interface is made available to pyFF via PyKCS11.

## Fail-over Configuration
Since the eToken Pro does not have a "cloning" feature, i.e., it does not
allow to export/safe/dump the content of the token (in some encrypted format) 
and restore it unto another token, you'll have to create the private key outside 
the token and load it on each token. Using a trusted off-line system for key 
creation, and secure physical storage for the off-line copy is recommended.

### Setup on the Management System 
1. Prepare a dedicated management system that is not used for any other 
   purpose. Make sure to encrypt either the hard disk or file systems. Ideally
   it is a live system booted from a read-only storage device.
2. Use the pki tool of your choice to generate the RSA key pair and 
   save it in a PKCS#12 keystore. See the example with OpenSSL below.
3. Use the "SafeNet Authentication Client" GUI tool to perform follwoing steps:
   - Connect the eToken via USB to the management system;
   - Initialize the token, deleting all existing data and setting token name and
     token password (no need for the admin password);
   - Configure it for 2048 RSA keys and FIPS-140-L2 mode;
   - Import the signing key and cert from the PKCS#12 keystore.
4. Repeat this for each token.
5. You may want to save the original key for backup storage, too. A protection
   for the key could be to split a large key between multiple persons, and use a
   derived key to AES-256 encrypt it, like the example below.
   openssl rand -base64 48 > keyN.txt # generate one random key per person
   cat key*.txt > openssl dgst -sha256 > enc_key.txt # derive encryption key 
   openssl enc -aes-256-cbc -kfile enc_key.txt -in hsm_private.key > hsm_private_key.enc 
   test if you can decrypt it:
   openssl enc -d -aes-256-cbc -kfile enc_key.txt -in hsm_private_key.enc > hsm_private_dup.key 
   diff hsm_private.key hsm_private_dup.key # must not show a difference!
6. Delete data on the management system to assure that the HSM private key cannot
   be recovered.

### Security Considerations
So you're losing out on the (more secure) generation of the private
key within the token (not using the OS libraries and random device),
which would give you cryptographic guarantees that there exists no
copy of the signing key outside the token.  This "HSM" just secures a copy of 
the key against attackers on the server, not /the/ one.
 
etoken Pro is limited to RSA key with 2048 bits, larger key sized would be
desireable for long-term keys. Also, as a proprietary product the
possibilities for independent verification are libited - even the driver is not 
open source. OTOH, it is a good risk mitigatation

You're also losing the cloning/backup/restore feature and you'll have
to do some form of backup (e.g. a USB-stick or CD-ROM with the
encrypted private key on it; the passphrase for decryption stored
somewhere else or shared among colleagues using something like
http://en.wikipedia.org/wiki/Shamir%27s_Secret_Sharing).

Tradeoff: The expenditure is low. You can move on from having your federation's 
private key sitting around in the file system for ~250 EUR (for 5 tokens). For
a good network HSM you can easily pay this for maintenance - weekly, per site. 

### Other options 
Nitrokey HSM has a similar price tag as the eToken Pro, and is a brand-new
product as of late 2015. Its driver is open source (OpenSC) as is the complete 
hardware and firmware.


## Examples
### Generating a Split Encryption Key
openssl rand -base64 96 | perl -pe 's/\n//' > random_str.b64  # 128 chars
split -a 1 -b 32 random_str.b64 enc_key_   # 4 key files with 32 chars each
cat enc_key_a  enc_key_b  enc_key_c  enc_key_d > enc_key.b64


### Generating a Key Pair and Certifikate as PKCS#12 with OpenSSL
// The resulting provate key will be unencrypted. This is required for the import to the eToken.
openssl req -newkey rsa:2048 -nodes -x509 -new -out hsm_root_crt.pem -keyout hsm_root_key.pem -days 7300 \
   -subj "/C=AT/O=Stadt Wien/OU=MA14/CN=Portalverbund Metadaten Signator" -batch 
openssl x509 -text -noout -in hsm_root_crt.pem > hsm_root_crt.txt 
openssl pkcs12 -export -in hsm_root_crt.pem -inkey hsm_root_key.pem -out hsm_root_crt.p12 -name "Portalverbund Metadata Signing Key" 

### Initializing the eToke Pro from the command line
// As an alternative to the GUI tool supplied by SafeNet, you might want to initialize the token in the command line.
echo Initializing Token
pkcs11-tool --module /usr/lib64/libeToken.so --init-token --label test --pin secret1 --so-pin secret2 
echo Initializing User PIN
pkcs11-tool --module /usr/lib64/libeToken.so -l --init-pin --pin secret1 --so-pin secret2
echo Generating RSA key (cannot be exported!)
pkcs11-tool --module /usr/lib64/libeToken.so -l -k --key-type rsa:2048 -d 1 --label test --pin secret1 
echo Checking objects on eToken
pkcs11-tool --module /usr/lib64/libeToken.so -l -O --pin secret1 


(Based on text from Peter Schober, Aconet) 
