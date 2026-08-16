# How does a process choose the port to initiate a connection?

Arbitrarily.  For example, start Firefox, and run:

    $ lsof -i nP | grep firefox
                            v---v
    firefox-b ... 127.0.0.1:43285->127.0.0.53:53
    firefox-b ... 127.0.0.1:52681->127.0.0.53:53
    firefox-b ... 127.0.0.1:56740->127.0.0.53:53
                            ^---^
                            random ports
    ...

# How does a server process handle a connection, usually?

A  master process  listens for  connections with  a listening  socket.  When  it
receives  a connection  request  from a  client,  it can  accept  it by  calling
`accept(2)`, which has 2 effects:

   - it creates a read/write socket with `socket(2)`, which will be dedicated to
     the connection with that particular client

   - it creates a child with `fork(2)`, which will handle the connection with
     that client; the child will use the previously created socket to
     communicate with the client

---

    $ ssh -N -p 2222 localhost
    # press C-z to suspend

    $ pstree -s $(pidof -s sshd)
    systemd───sshd───sshd───sshd
              ^--^   ^--^   ^--^
               |      |     child of child handling session (for privilege separation)
               |      child handling given connection
               master process listening for connections

    $ fg
    # press C-c to kill ssh(1)

##
# Why should I reduce intrusion attempts into my server?

Even if  it's properly configured and  secure, those attempts consume  CPU time,
and create noise in your logs which makes it harder to notice real problems.

## How to do it?

Use `fail2ban(1)`: a script blocking IP addresses that repeatedly try to connect
but fail to authenticate.

It works by monitoring log files (e.g. `/var/log/auth.log`).  When a remote host
fails to authenticate  too many times in a given  time frame, `fail2ban(1)` uses
`iptables(8)` to create  a rule to deny  traffic from that host.   Once the host
has given up trying to connect for long enough, `fail2ban(1)` removes the rule.

---

Also, if your server  is not meant to be accessed by any  IP, but just a limited
list, configure  its packet  filter (e.g. `iptables(8)`)  to only  allow traffic
from this list.
