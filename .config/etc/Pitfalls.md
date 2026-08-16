# Avoid hard-coding a username (e.g. `lgc`) or a host name (e.g.  `ubuntu`) in these files.

We might work with a different user or on a different host.

If    that's   not    possible   for    a   given    file,   make    sure   that
`~/bin/linux-installation-checklist`  edits it  with `sed(1)`,  so that  when we
restore our configuration on a new  machine, a hard-coded user/host name matches
the current one (as given by `$USER` and `/etc/hostname`).  For example:

    $ sudo sed -i'.bak' "s/^autologin-user=.*/autologin-user=$USER/" /etc/lightdm/lightdm.conf

# Don't edit `/etc/ld.so.conf` (nor `/etc/ld.so.conf.d/*`).

The more  you paths  you add  to it,  the bigger  the risk  you break  a program
because of a mismatched library.

---

If you want to  compile a program that needs an obscure library  path, add it to
its runtime library search path (see navi snippet).
