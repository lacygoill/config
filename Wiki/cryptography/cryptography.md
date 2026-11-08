# Which digital signature algorithm should I choose?

In decreasing order of preference: EdDSA, ECDSA, RSA.

EdDSA (2011) is more modern than ECDSA  (1992), which itself is more modern than
RSA (1977).

Besides, EdDSA keys are (about twice)  shorter than ECDSA keys, which themselves
are (about 2 to 3 times) shorter than RSA keys.

Finally, EdDSA is more secure than ECDSA:

   - the two curves (253-bit Curve25519 and 456-bit Curve448) that it
     supports are immune to timing attacks

   - during signing, it cannot leak private keys because of bad RNG

   - it's designed to make it difficult to make implementation mistakes that
     might weaken security

---

Also, read this:

   > Which digital signature algorithm should you choose?
   >
   > Recently, the EdDSA algorithm and  Curve25519 have become quite popular.
   > Curve25519  appears to  be trusted  by many  security experts.   If your
   > data  to  be  signed  always  fits  into memory  and  you  do  not  need
   > compatibility with old  software, choose EdDSA.  It  is worth mentioning
   > that, at the time of this  writing, major Certificate Authorities do not
   > issue  EdDSA-based X.509  certificates yet.   Hence, if  you need  a TLS
   > certificate for  a server  on the  internet, you will  need to  choose a
   > certificate  that's been  signed with  another algorithm,  for the  time
   > being.
   >
   > If you  want a more traditional  signature algorithm or want  to support
   > streaming, then choose ECDSA, which is also very popular.
   >
   > If you need interoperability with old software, or if you need very fast
   > signature verification, then choose RSA.

Source: the book "Demystifying Cryptography  with OpenSSL 3.0".

# Which cryptographic hash algorithm should I choose?

   > Which cryptographic hash function should you choose?
   >
   > So, which message digest function should you use in your new project?
   >
   > If your project  does not have special requirements,  choose SHA3-256.  This
   > function provides good security, is  well supported by crypto libraries, has
   > acceptable  performance,  and  is  future-proof.   Some  cryptographers  are
   > already advising people to migrate from SHA-2 to SHA-3.  It is expected that
   > SHA-3 functions will  get better support in the future  versions of security
   > standards and  protocols, such as  TLS, SSH, PGP, and  X.509, as well  as in
   > popular  software that  uses cryptography,  such  as web  browsers, PGP  and
   > GnuPG, various pieces of digital  signing software, and the password hashing
   > subsystems  of operating  systems and  websites.  It  is also  expected that
   > newer  CPUs  and dedicated  cryptography  chips  will gain  better  hardware
   > acceleration for SHA-3 algorithms.
   >
   > If you need  more compatibility and interoperability  with existing software
   > here and now, choose SHA-256 from the SHA-2 family.  But be ready to migrate
   > to an SHA-3 function if your SHA-2 security is broken.
   >
   > If you want more speed and  security, and interoperability is not a problem,
   > then choose the BLAKE2b function with a 512-bit message digest.  It has very
   > good security  and is noticeably faster  than the BLAKE2s, SHA-2,  and SHA-3
   > functions on 64-bit CPUs.

Source: the book "Demystifying Cryptography with OpenSSL 3.0".

# How many bits of security is enough for cryptographic algorithms?

According to NIST:

   - 112 bits of security should be enough until 2030
   - 128 bits of security should be enough until the next revolutionary
     breakthrough in technology or mathematics

For  an RSA  key, you  get 112  and  128 bits  of security  with a  key size  of
resp. 2048 and 3072 bits.

For an elliptic  curve key (e.g. ECDSA or EdDSA), you  get approximately half of
the key length in security bits.

---

The  next  expected  breakthrough  is quantum  computing.   Right  now,  quantum
computers are  still too expensive and  not powerful enough, and  that shouldn't
change until the 2030s at the earliest.

But  one day,  quantum  computers will  break  current *asymmetric*  algorithms.
You'll  then have  to use  a standardized  post-quantum cryptographic  algorithm
(there is none yet, but many cryptographers are working on such algorithms).

Quantum computers won't break *symmetric*  algorithms.  They'll only halve their
number of  security bits.  A symmetric  key which is 128-bit  strong *now*, will
become only 64-bit strong *then*.  That's  why 256 bits is recommended *now* for
a symmetric key size.
