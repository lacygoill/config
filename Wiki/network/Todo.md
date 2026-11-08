# Figure out how different `sshd(8)` processes can use the same port.

In the glossary, when defining "port", you wrote:

   > Only one process can open a given port at a time.

I read that from the "SSH Mastery" book.

But that doesn't seem to be completely exact:

    $ ssh -p 2222 localhost

    $ sudo lsof -i 4TCP -nP | grep ssh
    sshd 111 root ... *:2222 (LISTEN)
                        ^--^
    ssh  333  lgc ... 127.0.0.1:6666->127.0.0.1:2222 (ESTABLISHED)
    sshd 444 root ... 127.0.0.1:2222->127.0.0.1:6666 (ESTABLISHED)
                                ^--^
    sshd 555  lgc ... 127.0.0.1:2222->127.0.0.1:6666 (ESTABLISHED)
                                ^--^

Notice that we  have 3 different processes (they have  different PIDs) all using
the same  port `2222` at the  same time.  When  the `ssh(1)` process on  the 2nd
line sends  a packet to port  `2222`, how does  TCP (or the kernel?)  know which
`sshd(8)` process to give it to?

# Document how to run an arbitrary script once a network interface is activated.

It depends on what you use to configure the network.

For  `ifupdown(8)`, use  the `iface`  option `up`  to specify  the path  to your
script, which should be executed once the interface is up:

    auto eth0
    iface eth0 inet static
        address ...
        network ...
        netmask ...
        broadcast ...
        up /path/to/my/script
        ^-------------------^

See `man 5 interfaces /IFACE OPTIONS/;/^\s*up\>`:

   > up command, post-up command
   >        Run  command after bringing the interface up.  If this command fails then ifup aborts,
   >        refraining from marking the interface as configured (even though it has really been
   >        configured), prints an error  message, and exits with status 0.  This behavior may
   >        change in the future.

For `NetworkManager(8)`, see `man 8 NetworkManager /DISPATCHER SCRIPTS/;/^\s*up`.
And for `systemd-networkd(8)`, I don't know.

##
# Network Manager
## Look for `nmcli` and `network.*manager` in `~/.local/share/weechat/logs/#debian*`:

    $ grepc 'nmcli\|network.*manager' ~/.local/share/weechat/logs/#debian*

## Document the `NetworkManager` service.

    $ systemctl is-enabled --full NetworkManager
    $ systemctl is-active NetworkManager
    $ systemctl cat NetworkManager

## NetworkManager has a desktop applet.  Document its existence.

Also, the GUI window opened by  pressing on its "Edit Connections..." button can
be opened and scripted with `nm-connection-editor(1)`.

##
# In `~/Ebooks/Linux/linux_admin_handbook.pdf`, read:
## 8.2 Configuring the Network

   > If a configuration is required (for  example, for a WiFi interface), then it
   > will create the appropriate file in /etc/NetworkManager/system-connections/.

The directory is empty on Ubuntu 20.04.
But on Debian 12, there is a file named `Wired connection 1` in there:

    [connection]
    id=Wired connection 1
    uuid=50c49cf3-3433-46e4-905e-e9514cbf9720
    type=802-3-ethernet

    [802-3-ethernet]

    [ipv4]
    method=auto

    [ipv6]
    method=auto
    ip6-privacy=2

---

   > You  can  create   “System  connections”  that  are  used   as  soon  as
   > the   computer  boots   either   manually  with   a   `.ini`-like  file   in
   > `/etc/NetworkManager/system-connections/`  or   through  a   graphical  tool
   > (`nm-connection-editor`).  If  you were  using `ifupdown`, just  remember to
   > deactivate the  entries in  `/etc/network/interfaces` that you  want Network
   > Manager to handle.

---

   > If  Network Manager  is not  installed,  then the  installer will  configure
   > `ifupdown` by creating the  `/etc/network/interfaces` file.  A line starting
   > with  auto gives  a list  of interfaces  to be  automatically configured  on
   > boot  by  the  `networking`  service.   When there  are  many  interfaces,  it
   > is  good  practice to  keep  the  configuration  in different  files  inside
   > `/etc/network/interfaces.d/`.

On Ubuntu 20.04, there is no `networking` service, but there is one on Debian 12:

    $ systemctl is-enabled --full networking
    enabled
      /etc/systemd/system/network-online.target.wants/networking.service
      /etc/systemd/system/multi-user.target.wants/networking.service

    $ systemctl is-active networking
    active

    $ systemctl cat networking
    # /lib/systemd/system/networking.service
    [Unit]
    Description=Raise network interfaces
    Documentation=man:interfaces(5)
    DefaultDependencies=no
    Wants=network.target ifupdown-pre.service
    After=local-fs.target network-pre.target apparmor.service systemd-sysctl.service systemd-modules-load.service ifupdown-pre.service
    Before=network.target shutdown.target network-online.target
    Conflicts=shutdown.target

    [Install]
    WantedBy=multi-user.target
    WantedBy=network-online.target

    [Service]
    Type=oneshot
    EnvironmentFile=-/etc/default/networking
    ExecStart=/sbin/ifup -a --read-environment
    ExecStart=-/bin/sh -c 'if [ -f /run/network/restart-hotplug ]; then /sbin/ifup -a --read-environment --allow=hotplug; fi'
    ExecStop=/sbin/ifdown -a --read-environment --exclude=lo
    ExecStopPost=/usr/bin/touch /run/network/restart-hotplug
    RemainAfterExit=true
    TimeoutStartSec=5min

---

To continue...

## 8.3 Setting the Hostname and Configuring the Name Service

## 10 Network Infrastructure
##
# In `~/Ebooks/Linux/How_Linux_Works.pdf`, read:
## 9.14.1 NetworkManager Operation

Till the very end of the chapter 9.

## 10 Network Applications and Services

##
# In `~/Ebooks/Systemd.pdf`, read "15 Using systemd-networkd and systemd-resolved"

##
# Read /usr/share/doc/gawk-doc/gawkinet.pdf
