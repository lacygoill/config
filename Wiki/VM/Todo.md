# ?

For a VM to access the network, it needs a network card and a virtual interface.
This card can be connected to the network via 3 models:

   - the bridge model:  the eth0 network cards (both in the host and the guest)
     behave as if they were  directly plugged into an Ethernet switch

   - the routing model: the host behaves as a router that stands between the
     guest and the (physical) external network

   - the NAT model: the host  is again between the guest and the rest  of the
     network, but  the guest is  not directly accessible from outside, and
     traffic goes through some network  address translation on the host

# From the admin handbook, read "12.2.3. Virtualization with KVM".

KVM stands for Kernel-based Virtual Machine.

It's a kernel module  which lets a user space program (such  as QEMU) access the
virtualization features of various processors.

It's lightweight  because it takes  advantage of the processor  instruction sets
dedicated to virtualization (i.e. Intel-VT and  AMD-V).  The drawback is that it
only works with a processor which supports those instruction sets.

QEMU (Quick Emulator) is an emulator, which emulates the machine's processor and
provides a set of different hardware and device models for the machine, enabling
it to run a variety of guest operating systems.
It  can interoperate  with Kernel-based  Virtual  Machine (KVM)  to run  virtual
machines at near-native speed.

Unlike  VirtualBox, KVM  doesn't  include any  user-interface  for creating  and
managing  virtual  machines.   That's  where   the  `libvirt`  library  and  the
`virt-manager`  GUI come  in.  `libvirt`  lets you  manage  virtual machines  in
a  uniform  way, independently  of  the  virtualization system  involved  behind
the  scenes  (among  others,  it  supports  QEMU,  KVM,  VirtualBox,  and  LXC).
`virt-manager` is a graphical interface that uses `libvirt` to create and manage
virtual machines.

Installing the `virt-manager` package should pull in everything you need.
In practice,  you'll create  your VMs with  `virt-install(1)`, manage  them with
`virsh(1)`, and display their graphical console with `virt-viewer(1)`.

---

To control  the `libvirtd`  daemon, you need  `sudo(8)`, or be  a member  of the
`libvirt` group.  To avoid having to give your credentials too often:

    # in Debian your user is not in the `libvirt` group (it might be in Ubuntu)
    $ sudo adduser "$USER" libvirt
    # log out for the command to take effect

Tell  `libvirtd`  where to  store  the  disk  images  (the default  location  is
`/var/lib/libvirt/images/`):

    # create and start a pool object named `srv-kvm` and of type `dir`,
    # which maps to `/srv/kvm/` into the host filesystem
    $ mkdir /srv/kvm
    $ virsh pool-create-as srv-kvm dir --target=/srv/kvm

        A storage  pool is a quantity  of storage set aside  by an administrator
        for use by virtual machines.
        Storage pools  are divided into  storage volumes, which are  assigned to
        VMs as block devices.

        For  example, the  administrator responsible  for an  NFS (Network  File
        Sharing) server creates a share to store virtual machines' data.
        The administrator  defines a  pool on the  virtualization host  with the
        details  of the  share  (e.g.  nfs.example.com:/path/to/share should  be
        mounted on /vm_data).
        When the  pool is  started, libvirt  mounts the  share on  the specified
        directory, just  as if  the administrator logged  in and  executed mount
        nfs.example.com:/path/to/share /vmdata.
        If the  pool is configured  to autostart,  libvirt ensures that  the NFS
        share is mounted on the directory specified when libvirt is started.

        Once the  pool is started,  the files in the  NFS share are  reported as
        volumes, and the storage volumes' paths may be queried using the libvirt
        APIs.
        The volumes'  paths can then  be copied into the  section of a  VM's XML
        definition describing the source storage for the VM's block devices.
        In the case of NFS, an  application using the libvirt methods can create
        and delete volumes in the pool (files  in the NFS share) up to the limit
        of the size of the pool (the storage capacity of the share).
        Not all pool types support creating and deleting volumes.
        Stopping the pool  (somewhat unfortunately referred to by  virsh and the
        API  as  "pool-destroy")  undoes  the start  operation,  in  this  case,
        unmounting the NFS share.
        The data on the share is  not modified by the destroy operation, despite
        the name.
        See man virsh for more details.

        https://libvirt-python.readthedocs.io/storage-pools/


    # ???
    $ virsh pool-list
     Name      State    Autostart
    -------------------------------
     srv-kvm   active   no

#
# Document how to share the clipboard between the host and the guest.

Install the `spice-vdagent` package in the guest.  Then, reboot.

# Document how to release the cursor when it has been "captured" by the guest.

To release the cursor, press left CTRL and left ALT simultaneously.
See: `man virt-viewer /OPTIONS/;/--hotkeys`

# Document that some characters should be avoided when choosing a login name and password.

    amqwz
    AMQWZ

Those characters are  difficult to type correctly if the  host and guest systems
are using  different keyboard layouts (e.g.  azerty vs qwerty), when  you try to
install the guest system, as well as when you log in for the first time.

#
# How to share files?

<https://blog.sergeantbiggs.net/posts/file-sharing-with-qemu-and-virt-manager/>

Issue: Our current `virt-manager` is too old to enable shared memory:

   > Virtiofs needs  shared memory to work. This  can be enabled in  the hardware
   > configuration  window. Navigate  to Hardware  ->  Memory  and select  Enable
   > shared memory.

Workaround: Install `openssh-server` on both the guest and the host, and use `scp(1)`.

    $ scp -P 22 /path/to/file/on/host john@192.168.122.???:/path/to/dir/on/guest

On  a   recent  Ubuntu,   you  might   need  to  start   the  SSH   server  with
`$ systemctl start ...`,  but not  on Debian.   Some popular  distros no  longer
start services automatically when a  package is installed (probably for security
reasons).

Do we need to install `openssh-client` too?
What about `ssh`?  It doesn't seem to be pulled in by `openssh-{server,client}`.

Document that when  you specify a non-existing directory on  the guest, `scp(1)`
gives  a  confusing error  message.   Also,  document  that inputting  the  user
password is tricky  if it contains digits.   It seems you can't  use the numpad;
only  shifted keys  above the  AZERTY line.   Edit: Actually, the  issue is  not
specific to `scp(1)`; you just need to  make sure the Numlock key is enabled, so
that the numpad works.

How to avoid having to give our password each time we send a file?

# How to toggle full screen?

You can hover your mouse at the top  of the window, in the middle, then click on
the left icon displaying two arrows pointing to each other.
There should be a  hotkey too.  I think it's CTRL-ALT-F, but  it doesn't work in
XFCE; probably because the latter intercepts the keypress and starts Thunar.
Should we choose a  different hotkey?  Or should we configure  XFCE in the guest
to remove the intercepting shortcut?

# How to use a USB device connected on the host from a KVM VM?

#
# Should we find/write some fish completion for `virt-install(1)`?

It seems we already have one for `virsh(1)`.
And what about `virt-manager(1)`/`virt-viewer(1)`?
