# What are those `.pem` files?

Self-signed certificates used to authenticate to IRC servers via CertFP.

##
# One of the certificates expired!  How to install a new one?

    $ openssl req \
        -days=1096 \
        -keyout=<server>.pem \
        -newkey=rsa:2048 \
        -nodes \
        -out=<server>.pem \
        -sha256 \
        -subj="/CN=$USER" \
        -x509

    /set irc.server.<server>.sasl_mechanism plain
    /reconnect <server>

    /msg nickserv identify <password>

    # note fingerprint of expired certificate
    /msg nickserv cert list
    # delete it
    /msg nickserv cert del <fingerprint of expired certificate>

    # add fingerprint of new certificate
    /msg nickserv cert add
    # on OFTC, run this instead:
    #     /msg nickserv cert add <nick>
    # on Rizon:
    #     /msg nickserv access add fingerprint
                                   ^---------^
                                   to be typed literally;
                                   don't replace with an actual fingerprint

    /set irc.server.<server>.sasl_mechanism external

## `-days`

Number of days to certify the certificate for.

## `-keyout`

Where to write the created private key.   Without, the key would be written in a
separate  `privkey.pem` file,  which  you  would later  need  to  append to  the
certificate:

    $ cat privkey.pem >> <server>.pem

## `-newkey`

Create a new certificate request *and* a new private key.  The key uses 2048-bit
RSA (it's the  default anyway, but it lets  you know that it can  be set).  2048
bits is enough until 2030:

   > Since 2015, NIST recommends a minimum  of 2048-bit keys for RSA, ...
   > [...]
   > In  2003, RSA  Security  claimed  that 1024-bit  keys  were  likely to  become
   > crackable some time between 2006 and  2010, while 2048-bit keys are sufficient
   > **until 2030**.  As  of 2020 the largest  RSA key publicly known to  be cracked is
   > RSA-250 with 829 bits.

Source: <https://en.wikipedia.org/wiki/Key_size#Asymmetric_algorithm_key_lengths>

Doubling the size up to 4096 bits seems overkill for now.

## `-nodes`

Do not encrypt the created private key.
"nodes" stands for "no DES".

## `-out`

Where to write the self-signed certificate.

## `-sha256`

Use SHA256 for the signature algorithm (it's the default anyway, but it lets you
know that it can be set).

---

Other digests are supported:

    $ openssl req -help 2>&1 | grep digest
    -*                  Any supported digest

---

Note that SHA-256 is just as secure as SHA-384 or SHA-512.
See: <https://security.stackexchange.com/a/165568>

## `-subj`

Set subject  name for new  request.  Without, you would  be prompted to  fill in
various fields.  Also:

   > Most of these fields are fairly arbitrary, but the Common Name is important. It must
   > match the name of the subdomain you want to serve. If, for instance, you want to
   > serve TLS for www.admin.com, make that your Common Name. You can request
   > multiple names for a single certificate or a wild card that matches all the names in
   > a subdomain; for example, *.admin.com.

Source: Unix and Linux System Administration Handbook

   > The most important key is CN, which means Common Name. It is the main name of
   > the entity identified by the certificate.  It can be a website name, such as
   > www.openssl.org; a person's name, such as John Doe; or, if a certificate is
   > needed for a technical purpose, the name of the certificate itself, for
   > example, Technical certificate 123 or just R3.

Source: Demystifying Cryptography with OpenSSL 3.0

---

The value must be formatted as:

    /type0=value0/type1=value1/type2=....

## `-x509`

Output a self-signed certificate instead of a certificate request.
