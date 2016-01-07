# HSM with Gemalto/SafeNet/Alladin eToken Pro
http://www.safenet-inc.de/data-protection/authentication/etoken-pro/

The eToken Pro is a USB-format smartcard.  Attached to an internal USB connector 
on the machine hosting the pyFF instance signatures can be created on the HSM 
via a PKCSä11 interface, thus not exposing the private key to the server.

The machine running pyFF (Linux 2.6 kernel) need to have the etoken driver
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
   save it in a PKCS#12 keystore.
3. Use the Gemalto/SafeNet Authentication Client GUI tool to initialize the token for 
   2048 RSA keys and FIPS mode, and also to import the private key and cert 
   from the PKCS#12 keystore.
4. Repeat this for each token.
5. You may want to save the original key for backup storage, too. A protection
   for the key could be to split a large key between multiple persons, and use a
   derived key to AES-256 encrypt it, like this:
   openssl rand -base64 48 > keyN.txt # generate one random key per person
   cat key*.txt > openssl dgst -sha256 > enc_key.txt # derive encryption key 
   openssl enc -aes-256-cbc -kfile enc_key.txt -in hsm_private.key > hsm_private_key.enc 
   test if you can decrypt it:
   openssl enc -d -aes-256-cbc -kfile enc_key.txt -in hsm_private_key.enc > hsm_private_dup.key 
   diff hsm_private.key hsm_private_dup.key # must not show a difference!
6. Delete data on the management system to assure that theHSM private key cannot
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
product as of late 2015. It'S driver is open source (OpenSC).


(Based on text from Peter Schober, Aconet) 
