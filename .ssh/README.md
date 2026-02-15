# What is the purpose of
## this directory?

It contains SSH public and private keys which are used to authenticate to remote
servers.

It also contains per-user client  configuration overrides (which take precedence
over `/etc/ssh/ssh_config[.d]`).

---

All files have `0644` permissions, except:

   - private keys (`id_<algorithm>`) which should have `0600`
   - the client's `config` which *might* have `0664` (depends on the umask I guess)

With regard to `config`:

   > Because of the potential for abuse, this file must have strict permissions:
   > read/write  for  the  user,  and  not   writable  by  others.   **It  may  be**
   > **group-writable provided that the group in question contains only the user**.

Source: `man ssh /FILES/;/permissions`

Currently, our config file is group-writable, its group is `lgc`, and that group
only contains the user `lgc`:

    $ getent group lgc
    lgc:x:1000:
               ^
               no extra member

###
## `authorized_keys`?

It lets you authenticate to the local  SSH server (running on this machine) from
a remote client.

It's not read by your remote SSH  *client*, but by the local SSH *server*, which
might be confusing because you might think  that `~/.ssh/` is *only* meant to be
read by a client; it's not.

If the  remote client finds a  key pair in its  own `~/.ssh/`, it can  offer the
public key  to the  local server.  The  latter then compares  that key  with the
lines in `authorized_keys`.  If it matches any  one of them, and your client can
successfully exchange data  with that key, then it has  demonstrated that it has
the corresponding private key, and access is granted.

---

`authorized_keys`  can contain  several  lines because  you  might connect  from
different machines; each should have their  own key (not a requirement, but more
secure).  And even if you only connect  from a single machine, you might want to
use different encryption algorithms (e.g. RSA  vs ECDSA), each requiring its own
key.

---

If  one of  your  remote client  machine  is compromised,  remove  its key  from
`authorized_keys`.   If you  still  have access  to the  machine  and trust  it,
generate a new one over there, and add it to the file over here.

###
## `cm_sockets`?

We use it to store sockets necessary for connection multiplexing.

See `man ssh_config /^\s*ControlMaster`.

##
## `id_*` files?

Those are key pairs which you can use to authenticate to a server.

### How is that better than a password?

It's impossible to brute force a key  file because it's harder to reproduce than
a password (it contains several orders of magnitude more characters).

Besides, with  a key  file, you  don't send any  sensitive information  over the
network or  to the server  (which might be a  spoof server).  Instead,  you just
confirm that you're able to exchange data  encrypted with a public key stored in
the `authorized_keys` file in your account  on the server, which proves that you
have the corresponding  private key (the latter is only  decrypted locally; it's
*not* sent to the server).

---

A network  of compromised machines  dubbed the “Hail Mary  Cloud” repeatedly
scans  the  Internet  for SSH  servers.   When  a  cloud  member finds  one,  it
lets  the  other  members know  about  it.   Then,  each  member tries  a  *few*
passwords/usernames (not enough  for `fail2ban(1)` to block its  IP).  Since the
attempts are  constant, if the  password is  not complex enough,  eventually the
Hail Mary Cloud will guess it.

This works because  a simple password is  easy to reproduce (it  only contains a
few characters);  it wouldn't  work for  a key file  which contains  hundreds of
characters.

###
## `known_hosts`?

It  saves the  public  keys  of the  remote  servers  whose authenticity  you've
established.

Lines in this  file end with the  server's public key fingerprint  as written in
`/etc/ssh/ssh_host_<algo>.pub`:

    ... ecdsa-sha2-nistp256 AAAAE2VjZH...

### What about `known_hosts.old`?

It's meant to preserve the original contents of `known_hosts` before hashing it with:

    $ ssh-keygen -H [-f ~/.ssh/known_hosts]
                 ^^

   > -H      Hash a known_hosts file.  This replaces all hostnames and ad‐
   >         dresses with hashed representations within the specified file;
   >         the original content is moved to a file with a .old suffix.

Source: `man ssh-keygen /^\s*-H`

It also preserves its contents before removing keys with `-R`:

                 vv
    $ ssh-keygen -R 192.168.122.17 [-f ~/.ssh/known_hosts]
    # Host 192.168.122.17 found: line 1
    /home/lgc/.ssh/known_hosts updated.
    Original contents retained as /home/lgc/.ssh/known_hosts.old
                                                            ^--^

---

It's not meant  to be kept permanently.   Its purpose is to let  you restore the
original key cache, should  the new one not work.  As soon  as you have verified
that you can still connect to all your usual hosts, you can delete it.

### What is the meaning of the first field on each line?

By default it  should be a comma-separated list of  patterns matched against the
host name  of the  server (actually,  there might be  an optional  markers field
before).   But if  `HashKnownHosts`  is set  to `yes`,  (it  is on  Debian-based
systems in  `/etc/ssh/ssh_config`), then  it's a  single host  name stored  in a
hashed form to remain hidden even in case the file's contents is disclosed:

   > Alternately, hostnames may be stored in a hashed form which hides host
   > names and addresses should the file's contents be disclosed.  Hashed
   > hostnames start with a ‘|’ character.

Source: `man 8 sshd /SSH_KNOWN_HOSTS FILE FORMAT`
See also: `man ssh_config /^\s*HashKnownHosts`.

###
## `rc`?

It's a `sh(1)` script meant to run arbitrary commands whenever your user logs in.
Use it as you see fit.

For more info: `man sshd /^SSHRC`.
