# Should we use elliptic curve cryptography for our certificates?

Rationale:

   > I also think that **it is even  better to use Elliptic Curve Cryptography (ECC)**
   > **instead of RSA** in cases where the usage of ECC is as easy as the usage of RSA
   > – for example, **in TLS certificates** and SSH keys.

Source: the "Demystifying Cryptography with OpenSSL 3.0" book.

Also, EdDSA is more modern than RSA (2011 vs 1977).

---

Does WeeChat need to support whatever encryption algorithm we choose?
What about IRC servers?

---

Try this command:

    $ openssl req \
      -days=400 \
      -keyout=<server>.pem \
      -newkey=ec \
      -pkeyopt=ec_paramgen_curve:secp256k1 \
      -nodes \
      -out=<server>.pem \
      -sha256 \
      -subj="/CN=$USER" \
      -x509

It's   mostly   identical   to   the   one  we   run   to   generate   our   RSA
certificates,  except  that  it  replaces  `rsa` with  `ec`,  and  it  adds  the
`-pkeyopt=ec_paramgen_curve:secp256k1` argument.

Without `-pkeyopt`, an error is given:

    error:
    100C708B:
    elliptic curve routines:
    pkey_ec_keygen:no parameters set:
    ../crypto/ec/ec_pmeth.c:420:

This argument specifies that we want to use the curve named `secp256k1`.
Other possible curve names can be found with:

    $ openssl ecparam -list_curves

I think `secp256k1` is good enough, because  it means that the key length is 256
bits:

   > When you're generating an ECDSA key, you have to choose a curve. A curve has
   > a name and defines how long an EC key will be when the key is generated based
   > on that curve. For instance, a key generated based on the NIST P-256 curve
   > will have a length of 256 bits.

Which provides about 128 bits of security:

   > The security level of an elliptic curve key is approximately half of the key
   > length.  For example, a 224-bit key has a 112-bit security level.

Which is more than the recommended 112 bits to go until 2030:

   > As of 2021, the consensus among security researchers and the recommendation
   > of the US' National Institute of Standards and Technology (NIST) is the
   > following:
   >
   >     • 112 bits of security should be enough until 2030.
   >     • 128 bits of security should be enough until the next revolutionary
   >       breakthrough in technology or mathematics.

Source: the "Demystifying Cryptography with OpenSSL 3.0" book.

---

In the output of this command:

    $ openssl ecparam -list_curves

Not sure what `SECG` means, but have a look at `ec(1ssl)`:

   > Note OpenSSL uses the private key format specified in
   > 'SEC 1: Elliptic Curve Cryptography' (http://www.secg.org/).

And at `postconf(5)`:

   > The curve with the X9.62 name "prime256v1" is also known under the SECG
   > name "secp256r1", but OpenSSL does not recognize the latter name.

# Install new certificates which expire earlier.

When we generated our certificates, we made them expire in 3 years.

But the "SSH Mastery" book recommends 1 year only:

   > How long should a certificate be good for? Rolling over certs every year
   > or so is most common.
   > [...]
   > In short, never plan to use certificates longer than a year, [...]

Technically, the author talks about a  different kind of certificate, but with a
very similar purpose, so I think their recommendation is relevant here too.

Also, still in the same book:

   > Don't set your certificates to expire in exactly one year, though.
   > Remember, life happens. Maybe you put on your calendar to renew all of
   > your certificates in 52 weeks, but you develop appendicitis the day before
   > and you're off work for three weeks. I allow at least a month of leeway for
   > such emergencies, so these examples assume we expire all certificates in
   > fifty-six weeks and five days.

So, set  up a  systemd timer  which reminds  you to  renew your  certificates in
exactly 1 year  via a local mail.   But when you receive  the reminder, generate
(and install) new certificates which expire in  – say – 400 days, instead of
365.  This way,  you have more than a  month to act upon the  reminder, which is
useful if you  have issues IRL which prevent you  from renewing the certificates
swiftly.

If  you have  an automation  system (e.g. Ansible),  forget about  the reminder.
Instead, use your automation to renew and deploy your certificates every year.
