# c
## CA

Certificate Authority; its purpose is to validate the authenticity of public keys.

---

If Alice wants to send Bob a private message, she must trust that the public key
she has for Bob is in fact his and not Mallory's.

Here is how  the PKI (Public Key  Infrastructure), used to implement  TLS on the
web, addresses this problem:

   - Bob (the sysadmin) sends a certificate signing request for his public key
     to a known CA (that he and Alice both trust)

   - the CA returns a certificate signed with its own private key
   - Bob installs the signed certificate and his private key on his Web server
   - Alice (the user's client) requests the public certificate from the Web server
   - the Web server replies with the public certificate

   - Alice checks the signature against her local trust store which came
     pre-installed with her system  (e.g.  on Debian,  see `ca-certificates`
     package)

---

Certificate authorities charge a fee for signing services.

In 2016, Let's  Encrypt was launched as a free  service that issues certificates
through an  automated system.  You should  consider it as a  “probably just as
secure” free alternative to commercial CAs.

## cipher

A cryptographic algorithm used to secure a message.

## ciphertext

Cryptographic message.

Contrary to a  *plaintext* message, an *unreadable*  ciphertext exhibits several
advantageous properties:

   - confidentiality: it can only be read by the intended recipient
   - integrity: it cannot be modified without detection
   - non-repudiation: its authenticity can be validated (i.e. the sender's identity)

## collision

Event in which 2 different inputs generate  the same output when given to a hash
algorithm.  Longer hash values reduce the  frequency of collisions but can never
eliminate them entirely.

##
# d
## /dev/urandom

Device driver providing a random data stream.

The latter  is obtained by  recording subtle  variations in system  behavior and
using  these as  sources  of  randomness to  feed  into  a pseudo-random  number
generator (that ensures the output will have reasonable statistical properties).
Sources include everything from the timing of  packets seen on a network, to the
timing of  hardware interrupts, to  the vagaries of communication  with hardware
devices such as disk drives.

---

Nothing that  runs in user  space can compete with  the quality of  the kernel's
random  number  generator.  That's  why  you  should never  allow  cryptographic
software to generate its own random data; always make sure it uses `/dev/random`
or `/dev/urandom`.

Prefer `/dev/urandom` over `/dev/random`:

   > The  /dev/random  interface  is  considered  a  legacy  interface,  and
   > /dev/urandom is preferred and sufficient in all use cases, [...]

Source: `man 4 random /DESCRIPTION/;/Usage/;/legacy`

## decryption

Reverse process of encryption.

## digital signature

Process in which Alice signs her message with her private key.
Bob then uses Alice's signature and her public key to validate its authenticity.
It proves that Alice, not Mallory, sent the message.

##
# e
## ECC

Elliptic Curve Cryptography  (ECC) is a form of public  key cryptography that is
based on  the algebraic structure of  elliptic curves over finite  fields, which
was invented in 1985.

Popular algorithms using ECC include ECDSA (1992) and EdDSA (2011).

## encryption

Process of using a cipher to convert *plaintext* messages to *unreadable* ciphertext.

##
# h
## hash algorithm/function

Mathematical function  which accepts input  data of  any length and  generates a
small, fixed-length value that is somehow derived from that data.

---

A “cryptographic” hash algorithm is designed to exhibit these properties:

   - Entanglement: every  bit of the  hash value depends  on every bit  of the
     input data.  On average, changing one  bit of input should cause 50%  of
     the hash bits to change.

   - Pseudo-randomness: hash  values are not random, but should still  be
     indistinguishable from random data.  They should  have  no detectable
     internal  structure,    no  apparent  relationship to  the input data,  and
     pass  all  known  statistical tests  of randomness.

   - Non-reversibility:  given a hash  value, it should  be computationally
     infeasible to discover an input that generates it.

---

Nowadays, the only cryptographic hash algorithms recommended for general use are
the SHA-2 and SHA-3 (Secure Hash Algorithm) families.

Each of them  include variants with different hash value  lengths.  For example,
SHA3-512 is the SHA-3 algorithm configured  to generate a 512-bit hash value.  A
SHA algorithm without a version number, e.g., SHA-256, always refers to a member
of the SHA-2 family.

## hash value (aka, hash, summary, digest, checksum, fingerprint)

Output value of a hash algorithm.

---

A “cryptographic” hash verifies the integrity of some data.  For example, it
can certify that a config or binary file has not been tampered with:

    # on trusted machine A
    $ sha256sum /etc/ssh/sshd_config
    180b7aff7e...981224f3cb  /etc/ssh/sshd_config
    ^---------------------^

    # on unknown machine B
    $ sha256sum /etc/ssh/sshd_config
    180b7aff7e...981224f3cb  /etc/ssh/sshd_config
    ^---------------------^

Here, we've checked that `/etc/ssh/sshd_config` has  the same hash when given to
`sha256sum` on machine A  and on machine B.  If we trust machine  A, then we can
trust the config file on machine B too.

##
# n
## NIST

The US' National Institute of Standards and Technology.

##
# p
## pseudo-random number generator

Program generating random-looking  data, using methods similar to  those of hash
functions.

This  is usually  a  poor option  for  cryptography because  once  you know  the
internal state of the generator, you can predict its output number exactly.

## public key cryptography (aka asymmetric cryptography)

Bob generates a pair of public/private keys.
The private key remains a secret, but the public key can be widely known.
When Alice wants to send Bob a message, she encrypts it with Bob's public key.
Bob, who holds the private key, is the only one who can decrypt the message.

Pro: solves  the problem of exchanging  a secret symmetric key  over an insecure
channel for the duration of an established session.
Con:  impractical  for  encrypting  large  quantities of  data  because  of  low
performance.

The most widely used public key algorithms are Diffie-Hellman and RSA.

##
# s
## symmetric key cryptography

Alice and Bob share a secret key that they use to encrypt and decrypt messages.

Pro: efficient in terms of CPU usage and size of ciphertext.
Con:  have  to  find  a  way  to  exchange  the  key  securely  without  Mallory
intercepting it (that's solved by *public* key cryptography).

The  most  widely used  symmetric  key  algorithm  is AES  (Advanced  Encryption
Standard).
