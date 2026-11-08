# investigate `podman-compose` in place of `docker-compose`

In  the book,  the section  9.4 (titled  "Using docker-compose  with the  Podman
service") tells you to install `docker-compose`.  On Ubuntu 20.04, that pulls 18
extra dependencies, which take 294 MB of space:

    $ sudo apt install docker-compose

In contrast, the  `podman-compose` pip package seems much smaller  and has fewer
dependencies:

    $ pipx install podman-compose

Are there other benefits?

See: <https://github.com/containers/podman-compose>

##
# define what a "volume" is

# define what a REST API is

<https://old.reddit.com/r/explainlikeimfive/comments/rypnmj/eli5_what_is_a_rest_api/>

##
# document how to undo the system changes applied by Docker

For  example,  to  reset  the  `iptables(8)` rules  (which  you  can  read  with
`$ sudo iptables -L`), this *seems* to work:

    $ sudo iptables -P INPUT ACCEPT
    $ sudo iptables -P FORWARD ACCEPT
    $ sudo iptables -P OUTPUT ACCEPT
    $ sudo iptables -t nat -F
    $ sudo iptables -t mangle -F
    $ sudo iptables -F
    $ sudo iptables -X

Source: <https://serverfault.com/a/200658>
But is it really correct and reliable?

BTW, compare our current default rules:

    Chain INPUT (policy ACCEPT)
    target     prot opt source               destination

    Chain FORWARD (policy ACCEPT)
    target     prot opt source               destination

    Chain OUTPUT (policy ACCEPT)
    target     prot opt source               destination

To this mess:

    Chain INPUT (policy ACCEPT)
    target     prot opt source               destination

    Chain FORWARD (policy ACCEPT)
    target     prot opt source               destination
    DOCKER-USER  all  --  anywhere             anywhere
    DOCKER-ISOLATION-STAGE-1  all  --  anywhere             anywhere
    ACCEPT     all  --  anywhere             anywhere             ctstate RELATED,ESTABLISHED
    DOCKER     all  --  anywhere             anywhere
    ACCEPT     all  --  anywhere             anywhere
    ACCEPT     all  --  anywhere             anywhere

    Chain OUTPUT (policy ACCEPT)
    target     prot opt source               destination

    Chain DOCKER (1 references)
    target     prot opt source               destination

    Chain DOCKER-ISOLATION-STAGE-1 (1 references)
    target     prot opt source               destination
    DOCKER-ISOLATION-STAGE-2  all  --  anywhere             anywhere
    RETURN     all  --  anywhere             anywhere

    Chain DOCKER-ISOLATION-STAGE-2 (1 references)
    target     prot opt source               destination
    DROP       all  --  anywhere             anywhere
    RETURN     all  --  anywhere             anywhere

    Chain DOCKER-USER (1 references)
    target     prot opt source               destination
    RETURN     all  --  anywhere             anywhere

Or maybe just reboot?

---

To   remove  the   virtual  network   interface   (which  you   can  find   with
`$ ip link show`):

    $ sudo ip link delete docker0

Or maybe just reboot?

---

    $ sudo delgroup docker

    # Is that still necessary after the previous command?
    $ sudo gpasswd --delete=lgc docker

---

    $ sudo rm -rf \
        /etc/docker \
        /var/lib/{containerd,docker} \
        /var/run/docker.sock

---

Are there other changes to undo?
See:

   - <https://askubuntu.com/questions/935569/how-to-completely-uninstall-docker>
   - <https://docs.docker.com/engine/install/ubuntu/#uninstall-docker-engine>

Test in a VM.

# document cgroups

A Linux sysadmin's introduction to cgroups:
<https://www.redhat.com/sysadmin/cgroups-part-one>

How to manage cgroups with CPUShares:
<https://www.redhat.com/sysadmin/cgroups-part-two>

Managing cgroups the hard way (manually):
<https://www.redhat.com/sysadmin/cgroups-part-three>

Managing cgroups with systemd:
<https://www.redhat.com/sysadmin/cgroups-part-four>

# document namespaces

The 7 most used Linux namespaces:
<https://www.redhat.com/sysadmin/7-linux-namespaces>

Building a Linux container by hand using namespaces:
<https://www.redhat.com/sysadmin/building-container-namespaces>

Building a container by hand using namespaces: The mount namespace:
<https://www.redhat.com/sysadmin/mount-namespaces>

Building containers by hand: The PID namespace:
<https://www.redhat.com/sysadmin/pid-namespace>

Building a container by hand using namespaces: The UTS namespace:
<https://www.redhat.com/sysadmin/uts-namespace>

Building containers by hand using namespaces: The net namespace:
<https://www.redhat.com/sysadmin/net-namespaces>

Building containers by hand using namespaces: Use a net namespace for VPNs:
<https://www.redhat.com/sysadmin/use-net-namespace-vpn>

# document namespaces+podman

Podman and user namespaces: A marriage made in heaven
<https://opensource.com/article/18/12/podman-and-user-namespaces>

Running rootless Podman as a non-root user:
<https://www.redhat.com/sysadmin/rootless-podman-makes-sense>

# document capabilities

<https://book.hacktricks.xyz/linux-hardening/privilege-escalation/linux-capabilities>
