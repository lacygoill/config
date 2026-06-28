# a
## abstraction

An abstraction involves ignoring most of the details of a system and focusing on
its basic purpose and operation.

In  software  development,  abstractions  are used  to  create  components  that
interact with  other components,  without needing  to understand  their internal
structure.

## API

Application Programming Interface

It's  a software  interface offered  by a  program as  a service,  to let  other
programs achieve specific  goals (e.g. the Twitter API lets  a client retrieve a
tweet from the Twitter servers).

A document/standard  that describes  how to  build or use  such an  interface is
called an  *API specification*.  A program that  meets this standard is  said to
*implement*  or  *expose*  an  API.   The  term API  may  refer  either  to  the
specification or to the implementation.

---

An API is often made up of different parts available to the programmer:

   - subroutines
   - methods
   - requests
   - endpoints

A program that uses one of these parts is said to *call that portion of the API*.
An API  specification defines these calls;  it explains how to  use or implement
them.

##
# b
## bit
### sticky bit (aka restricted deletion flag)

Special mode  bit which  can be given  to a directory.   It prevents  users from
(re)moving/renaming a file/subdirectory in a  given directory (even if they have
write permission on the latter), unless:

   - they own the file/subdirectory
   - they own the parent directory (with the sticky bit)
   - they're root

It's commonly found on world-writable directories like `/tmp`.

Linux ignores the sticky bit when applied to a file.  But on early Unix systems,
when applied to  a binary file, the  flag caused the program's text  image to be
saved on the swap device, so that it would load more quickly when run.

`/tmp/` is an example of directory with the sticky bit.

---

MRE:

    $ cd /tmp/
    $ mkdir dir
    $ touch dir/file
    $ sudo chown nobody:nogroup dir dir/file

                         v
    $ sudo chmod ug+w,o+wt dir
    $ rm -f dir/file
    rm: cannot remove 'dir/file': Operation not permitted
    $ sudo --group=nogroup rm -f dir/file
    rm: cannot remove 'dir/file': Operation not permitted

We can't  remove `dir/file` even though  we have write permission  on its parent
`dir/` in the last 2 commands (`o+w`, `g+w`).  That's because of the sticky bit.

But we can if we own either `dir/`:

                 or any user other than `nobody`
                 v--v
    $ sudo chown news dir/file

                  dir's owner
                  v----v
    $ sudo --user=nobody rm dir/file
    # no error

or we own `dir/file`:

    $ touch dir/file
    $ sudo chown news:nogroup dir/file

                  dir/file's owner
                  v--v
    $ sudo --user=news rm dir/file
    # no error

### set-group-ID/setgid bit

Special mode bit which can be given to either an executable or a directory.

When given to an executable, upon execution, the process's EGID (Effective Group
ID) is set  to that of the  file, while its RGID  (Real Group ID) is  set to the
actual  user (which  should be  the GID  of the  shell from  which the  file was
executed).

When given to a directory, files/subdirectories created inside are automatically
given the same group  as the directory, rather than the  group of their creator;
also, newly-created subdirectories are given the  setgid bit.  This is useful in
a shared  directory, where  members of  a common  group need  access to  all the
files, regardless of the file owner's primary group.

Examples of files with the setgid bit:

   - `/usr/bin/wall` (binary)
   - `/var/mail/` (directory)

### set-user-ID/setuid bit

Special mode bit which can be given to an executable.  Re-set the process's EUID
(Effective User  ID) to that  of the file upon  execution, while its  RUID (Real
User ID) is still  set to the actual user (which should be  the UID of the shell
from which the file was executed).

Most often  this is given  to a  few programs owned  by the superuser.   When an
ordinary user  runs a program  that is setuid root,  it runs with  the effective
privileges of the superuser.  This lets the program access files and directories
that an ordinary  user would normally be prohibited from  accessing.  The user's
privileges are thus promoted for the execution of that specific program only.

`/usr/bin/passwd` is an example of file with the setuid bit.

##
# c
## component

An abstracted subdivision  in computer software, such as a  subsystem, a module,
or a package; it's used to simplify complex systems.

##
# d
## (kernel) driver

A bit of compiled code which lets the kernel talk to some hardware device.
It "drives" the hardware.

A driver is a special kind of module.

##
# f
## file mode bits

Set of bits controlling the kinds of access that users have to a given file.  It
can be  represented either in  symbolic form (e.g.  `rwxrw-r--`) or as  an octal
number (`0764`).

It can be broken down into two parts:

   - the file permission bits which control ordinary access to the file
   - the special mode bits which affect only executables and directories (setuid
     bit, setgid bit, sticky bit)

## file permission bits

There are three kinds of permissions that a user can have for a file:

   1. permission to read it.  For directories, this means permission to list the
      its contents.

   2. permission to write/change it.  For directories, this means permission to
      create and (re)move files inside.

   3. permission to execute it.  For directories, this means permission to
      access files inside.

Those permissions can be granted to three categories of users:

   1. the file's owner
   2. other users who are in the file's group
   3. everyone else

##
# i
## ID
### RGID/EGID/SGID (aka Real/Effective/Saved Group ID)

The RGID  attribute of a process  is largely vestigial.  For  purposes of access
determination, a process can  be a member of many groups  at once.  The complete
group  list is  stored separately  from the  RGID and  EGID.  Determinations  of
access  permissions normally  take into  account the  EGID and  the supplemental
group list, but  not the RGID itself.  That  is, if a process tries  to access a
file and  their EUID  doesn't match  the file's owner,  Linux tests  whether the
file's  group  is in  the  process'  group list;  if  it  is, the  file's  group
permissions apply; otherwise, the file's other permissions apply.

The EGID is related to the RGID in the  same way that the EUID is related to the
RUID in that it can be “upgraded” by the execution of a setgid program.

As with the saved UID, the kernel maintains a saved GID for each process.

### RUID/EUID/SUID (aka Real/Effective/Saved User ID)

The **RUID** (Real User  ID) of a process defines who can  send it signals (e.g.
to kill  it), and more  generally who can interact  with it.  Usually,  it's the
user  who initiated  the  process.   However, the  process  can  re-set it  (via
`setuid(2)`) to the EUID.  For example, that's what happens with `sudo(8)`:

    $ sudo sleep 60
    # press C-z to suspend sleep(1)

    $ ps -e --format=pid,comm,ruser,euser | grep sudo
    1234 sudo root root
              ^--^

That's why you can't kill this `sleep(1)` as your regular user:

    $ pkill sleep
    pkill: killing pid 1234 failed: Operation not permitted

you still need `sudo(8)`:

    $ sudo pkill sleep
      ^--^

The  reason why  `sudo(8)` (and  many  setuid programs)  does this  is to  avoid
unintended side  effects and  access problems when  all of the  user IDs  do not
match.

The **EUID**  (Effective User ID) of  a process defines its  access rights (most
significantly  for file  permissions).   Usually, it's  identical  to the  RUID,
however  the  process can  re-set  it  (via `setuid(2)`)  to  the  owner of  the
executable file if  the latter has been  given the setuid bit.   Also, a process
running as root (user ID 0) can use `setuid(2)` to become any other user.

The **SUID**  (Saved User  ID) is  a copy  of the  EUID at  the moment  when the
process first begins  to execute.  It remains  available for use as  the RUID or
EUID.   A  conservatively written  setuid  program  can therefore  renounce  its
special privileges for the majority of  its execution (by re-setting its EUID to
its RUID) and access  them only at the moments when  extra privileges are needed
(by re-setting its EUID to its SUID).

##
## initramfs

The kernel needs  the driver for the  controller of the storage  device to mount
its root filesystem.   But distributions can't include all  the existing drivers
in  their  kernels.   So, many  of  them  are  shipped  as loadable  modules  in
`/boot/initrd.img` (which is a `gzip(1)`ped `cpio(1)` archive), along with a few
other utilities.  GRUB loads `initrd.img` into memory before running the kernel.
The latter extracts the contents of `initrd.img` into a temporary RAM filesystem
(the **initramfs**), mounts it at `/`, and runs an `sh(1)` init script:

    $ lsinitramfs -l /boot/initrd.img | grep ' init$'
    -rwxr-xr-x 1 root root [...] init

    $ unmkinitramfs /boot/initrd.img /tmp/initrd
    $ head --lines=1 /tmp/initrd/main/init
    #!/bin/sh

Then, the  initramfs' utilities allow  the kernel  to load the  necessary driver
modules for the  real root filesystem.  Finally, these utilities  mount the real
root filesystem and start `systemd(1)` (and `initrd.img` unloads).

You can  create an initramfs  image with `mkinitramfs(8)`, extract  its contents
with `unmkinitramfs(8)`, and list it with `lsinitramfs(8)`.

---

`initrd.img` stands for "initial RAM disk filesystem image".

##
# k
## kernel

File located at `/boot/vmlinuz`.  On boot, GRUB loads its image into the RAM.

The `z` in `vmlinuz` means that the image is compressed:

   > The symlinks for the primary default kernel version are  named  vmlinuz
   > or  vmlinux  (depending  on whether the architecture normally uses com‐
   > pressed kernel images) and initrd.img (if it uses an  initramfs).

Source: `man linux-update-symlinks(1)`

As for `vm`, I *guess* it stands for **v**irtual **m**emory (in which the kernel
image is loaded).

## kernel mode

Mode in which the kernel runs.  In  this mode, it has unrestricted access to the
processor and main memory.

## kernel space

Memory area strictly reserved for  running a privileged operating system kernel,
kernel extensions, and most device drivers.

It's  separated  from user  space  to  provide  memory protection  and  hardware
protection from malicious or errant software behaviour.

##
# l
## LXC

LXC  (LinuX Containers)  is a  system which  leverages control  groups (a  Linux
kernel feature) to  isolate groups of processes from each  other; i.e. they have
different views of  certain aspects of the overall system  (PIDs, network, mount
points, ...).

Such a  group of  isolated processes  has no  access to  other processes  in the
system,  and its  accesses to  the filesystem  can be  restricted to  a specific
subset.  It  can also  have its own  network interface +  routing table,  and be
configured to only see a subset of the available devices present on the system.

---

Contrary to a VM, which has  to virtualize everything including the hardware and
the kernel, a container uses the same kernel as its host system.

Pro:

   - excellent performance because no  overhead, and more efficient scheduling
     (the host kernel has a global vision  of all the processes  running on the
     system; with a VM, the host and guest kernels only see their respective
     processes)

Cons:

   - cannot  run a  different kernel (whether a different Linux version or
     a different OS altogether)

---

To run an LXC container, on Debian, you need the `lxc` package.
On Ubuntu, you need `lxc-utils`.

## layer

A classification or grouping of components  in a computing system based on their
position between the user and the hardware:

   - at the bottom layer is the hardware, including memory, CPUs, and devices
     such as disks and network interfaces

   - the next layer up is the kernel, which is the core of the operating system
     and manages the hardware, particularly memory, and acts as a mediator
     between the hardware and user processes

   - the upper level is user space

## locale

Group of regional settings:

   - language for text
   - format for displaying numbers, dates, times, and monetary sums
   - collation order
   ...

`locale(1)` lists these settings as a group of standard environment variables.

---

The name of a locale follows this scheme:

    language-code_COUNTRY-CODE.encoding
                              ^-------^
                              optional

Example:

    en_US.UTF-8
    ^^ ^^ ^---^
    |  |  encoding
    |  country
    language

---

A locale has an associated “character set” (group of known characters) and a
preferred  “encoding” (internal  representation  for  characters within  the
computer) like ISO-8859-1 (aka Latin 1) and ISO-8859-15 (aka Latin 9).

UTF-8 is the encoding that should generally  be used, and is thus the default on
Debian systems.

---

In a  script, if you  execute a  command whose output  might be affected  by the
locale,  and you  need it  to  be reliable/predictable,  you might  want to  set
`LC_ALL=C` in its environment:

    LC_ALL=C <cmd>

In the `C` locale, all characters are  encoded with ASCII using only 1 byte, and
the collation order is based solely on those bytes.

`LC_ALL=C`  will also  improve performance  significantly because  parsing UTF-8
data has a cost.

But  in  an  interactive  environment  (e.g. shell  init  file),  `LC_ALL=C`  is
undesirable because it prevents you from inserting accented characters.

---

Non-exhaustive list of things affected by the locale:

   - The  collation  order,   which  in  turn  affects  the  meaning   of
     a  bracket expression  such as  `[a-d]` in  a regex.   More specifically,
     `LC_COLLATE` and `LC_CTYPE` (`man 7 locale`).   If the locale  is `C`, then
     `[a-d]`  simply means `[abcd]`.  But in  a locale which sorts in dictionary
     order, `[a-d]` might mean `[aAbBcCd]`.

   - What `.` matches in a regex.  The latter  is meant to match a character.
     But if you're working in a UTF-8 locale, while  the input that you feed to
     `grep(1)` is encoded  in  Latin 9,  non-ASCII  characters  are likely  not
     to  form a  valid character in UTF-8.  As a result, `a.*b`  will
     unexpectedly fail to match a text starting  with `a`  and ending  with `b`
     if it  contains one  of those  invalid characters.  `LC_ALL=C` fixes  this
     issue, because any byte value  forms a valid character in the `C` locale.

   - A case-insensitive comparison (e.g. `$ grep -i`), or a case conversion
     (e.g. `awk(1)`'s `toupper()`).  For example, in  some Turkish locales,
     upper-case `i` is `İ` instead of `I`, and lower-case `I` is `ı` instead of `i`.

   - How a floating point number written in code is parsed by an application
     which honors `LC_NUMERIC` (the latter specifies the decimal separator).
     A computation which  works with one locale, might give  a syntax error with
     another.  For example:

                      v                         v
         $ LC_NUMERIC=C bash -c 'printf "%g\n" 0.01'
         0.01

                      v---------v                         v
         $ LC_NUMERIC=fr_FR.UTF-8 bash -c 'printf "%g\n" 0.01'
         bash: line 0: printf: 0.01: invalid number

   - How a generated floating point number is written:

                      v
         $ LC_NUMERIC=C bash -c 'printf "%g\n" 1e-2'
         0.01
          ^
                      v---------v
         $ LC_NUMERIC=fr_FR.UTF-8 bash -c 'printf "%g\n" 1e-2'
         0,01
          ^

    This matters if the number is  then fed to another application which expects
    the dot as the decimal separator.

## `lsof(8)`

This command lists processes holding file descriptors.

The output can be filtered with various flags.

One special flag is `-i` which filters the output so that only processes opening
internet sockets remain.  It lets you get a list of *network* processes.

---

In the FD column, the letters `r`, `w`, `u` after the numbers are modes:

    r = read
    w = write
    u = read + write

---

The TYPE column includes the type of the opened files:

    ┌──────┬────────────────────────┐
    │ DIR  │ directory              │
    ├──────┼────────────────────────┤
    │ REG  │ regular file           │
    ├──────┼────────────────────────┤
    │ CHR  │ character special file │
    ├──────┼────────────────────────┤
    │ unix │ UNIX domain socket     │
    └──────┴────────────────────────┘

DEVICE is the major and minor number of the device that holds the file.
SIZE/OFF is the file's size.
NODE is the file's inode number.

For more info: `man lsof /^\s*OUTPUT$`.

---

A file  might be missing from  `lsof(8)`'s output even  if you opened it  with a
program; that's the case with Vim for  example.  But Vim does open a swapfile if
`'swapfile'` is set.  If it's not set, Vim doesn't open anything, which suggests
that it  only opens a file  temporarily when it needs  to read that file  into a
buffer or to write a buffer into it.

##
# m
## (kernel) module

A bit  of compiled code that  can be inserted  into the kernel at  runtime; e.g.
with `insmod(1)` or `modprobe(1)`.

## mount

**Mount**ing  a  filesystem (that  can  be  found on  some  block  device) on  a
**mount** point is the process of **attach**ing  that  filesystem  to  the  file
hierarchy rooted at `/`, from which all files in the system are arranged.

Conversely, **unmount**ing a filesystem will **detach** it again.

##
# s
## superblock

Record that describes the characteristics of a filesystem:

   - information about the length of a disk block
   - size and location of the inode tables
   - disk block map and usage information
   - size of the block groups
     ...

##
# t
## time
### chrony

Implementation of NTP with the following features:

   - works well on computers that have unstable network connections or that get
     turned off for long periods (*1)

   - works with virtual machines (*2)

   - can achieve sub-microsecond accuracy by using hardware timestamping and
     a hardware reference clock

It's used by default on the RHEL and SUSE distributions.

(*1)  The  user   can  periodically  enter  the  correct  time   by  hand  (with
`chronyc(1)`).  Besides, `chronyd(8)` determines the  rate at which the computer
gains or loses time, and compensates for this.

(*2) Not sure about a VM, but `systemd-timesyncd(8)` doesn't work in a container,
because of its `ConditionVirtualization=!container` directive.

---

There are two components in the chrony system:

   - `chronyd(8)`: daemon which can run in either client or server mode

   - `chronyc(1)`: CLI interface which can be used to monitor the daemon, as
     well as fine-tune various parameters within it (e.g. add or delete servers
     whilst the daemon is running)

###
### clock
#### hardware clock

Hardware device  with its  own power  source (e.g. battery  or capacitor  on the
motherboard), that operates when the machine  is powered off, or even unplugged.
Its purpose is to  keep time when Linux is not running so  that the system clock
can be initialized from it at boot.

Also commonly called:

   - the real time clock (or RTC)
   - the BIOS clock
   - the CMOS clock
   - the persistent clock (by the Linux kernel)

On Debian/Ubuntu, during shutdown, it's updated to compensate for hardware clock
drift  and to  maintain  time  coherency when  the  system  reboots, by  running
`$ hwclock --systohc` (via `/etc/init.d/hwclock.sh`).

Pro: Persists across system reboots.
Con: Not very precise, and provides slow access times.

#### system clock

Maintained by  the kernel.  It's set  from the hardware clock  during boot, then
kept up-to-date with the help of time servers, which use the UTC timescale.

Pro: Accurate (*).
Con: Does not persist across system reboots.

(*) If the machine is connected to the  Internet and can send requests to a time
server.  If for some reason it can't, then the system clock is actually worse at
keeping time then the hardware clock (i.e. it accumulates even more time drift).

###
### leap second

Extra second which is  occasionally (once every few years, the  last day of June
or December) inserted after the last second of the UTC day.  In theory, it might
also be the last second of the UTC day which is deleted.

   > STA_INS (read-write)
   >        Insert a leap second after the last second of the UTC day,  thus
   >        extending the last minute of the day by one second.  Leap-second
   >        insertion will occur each day, so long as this flag remains set.

   > STA_DEL (read-write)
   >        Delete a leap second at the last second of the  UTC  day.   Leap
   >        second  deletion  will  occur each day, so long as this flag re‐
   >        mains set.

Source: `man 2 adjtimex`

Note that, so far,  all leap seconds have inserted extra  seconds.  None of them
has deleted one, and it's unlikely it happens in the foreseeable future:

   > Although the definition also includes the possibility of dropping seconds
   > ("negative" leap seconds), this has never been done and is unlikely to be
   > necessary in the foreseeable future.

Source: `/usr/share/zoneinfo/leap-seconds.list`

The purpose of leap seconds is:

   > to keep UTC to within 0.9 s of UT1
   > (a proxy for Earth's angle in space as measured by astronomers)

Source: `/usr/share/zoneinfo/leapseconds`

It's a  mechanism to account for  the discrepancy between atomic  time (TAI) and
the earth's rotation.

---

`/usr/share/zoneinfo/leap-seconds.list` is copied from
<ftp://ftp.nist.gov/pub/time/leap-seconds.list>.

Then, it's  used to  generate `/usr/share/zoneinfo/leapseconds`.  In  turn, that
file is used by `zic(8)` to  compile files documented by `tzfile(5)`.  See also:
`man 8 hwclock /DATE-TIME CONFIGURATION/;/^\s*POSIX vs 'RIGHT'`

Note that  the timestamps in `leap-seconds.list`  are in units of  seconds since
the *NTP* epoch (and not the Unix one) which is `1 January 1900, 00:00:00`.

---

The algorithm for  assigning a UTC timestamp  to an event that  happens during a
positive leap second is not well-defined.  The official name of that leap second
is `23:59:60`,  but there  is no  way of representing  that time.   Many systems
effectively stop the system clock for one  second during the leap second and use
a time that is equivalent to `23:59:59 UTC` twice.

### local time

System time, adjusted for your time zone correction and DST.

It's controlled  by `/etc/localtime`, which  is actually symlinked to  your time
zone file under `/usr/share/zoneinfo`.

###
### NTP

Network Time Protocol

Used to keep computer clocks accurate by synchronizing them over the Internet or
a local network.

Accurate time is required for:

   - scientific computing
   - log keeping
   - database updating
   - financial transactions (modern stock exchanges use automated trading bots)
   - some security protocols (e.g. Kerberos, DNSSEC, TLS)

---

A Linux system includes an (S)NTP client (e.g. `systemd-timesyncd(8)` or chrony)
which  obtains  the correct  time  from  a highly  accurate  NTP  server on  the
Internet, on boot and possibly regularly later.

### PTP

Precision Time Protocol

PTP  is designed  for  extreme timekeeping  accuracy, which  is  needed in  many
financial, scientific,  and enterprise  applications, and  can't be  obtained by
getting  the time  from  a remote  server  on the  Internet.   It uses  hardware
timestamping and hardware reference clocks to achieve picosecond accuracy.

Unlike NTP, PTP cannot  obtain its time from a remote time  server that's out on
the Internet.  Instead,  it can only be  used within a LAN and  obtains its time
from a local  source (aka the Grandmaster Clock), which  most likely obtains its
time from a GPS satellite, and then synchronizes the clocks on the other network
devices to the GPS time.

To  use it,  you must  have a  precision time  source on  your LAN,  as well  as
switches and routers that can work with it.

###
### system time

Time given by the system clock.
It can be read by running something like `$ date +'%s'`.

### time drift

The current difference between the system time  and the true time (as defined by
an atomic clock or  another very accurate clock).  An NTP  daemon is usually the
best way to compensate for time drift.

##
### timestamp

Each file is given 3 timestamps:

   - access timestamp (`atime`) of the last read

   - modification timestamp (`mtime`) of the last write

   - status change timestamp (`ctime`) of the last change to the file's
     meta-information

When you read a file, only `atime` is updated.
When you write a file, both `mtime` and `ctime` are updated.
When you move/rename/`chmod(1)` a file, only `ctime` is updated.

When you `touch(1)` a file, all timestamps are updated:

    $ rm -f /tmp/file; echo text >/tmp/file; sleep 2
    $ touch /tmp/file
    $ stat --printf='%X\n%Y\n%Z\n' /tmp/file
    1708546023
    1708546023
    1708546023
    ^--------^
    same number 3 times

For more info: `info coreutils /28 File timestamps`.

---

Do not conflate the timestamp of a file with its age.

The most recent  file is the one  with the *biggest* timestamp.   Another way of
putting it, the smaller the timestamp, the older the file is.

### timestamp file

File whose sole purpose is to find nodes which changed since last time something
noteworthy happened.  That something noteworthy might be – for example – the
creation  of an  archive.   Typically,  a timestamp  file  can  be updated  with
`touch(1)` so that `find(1)` can later compare its last data modification to one
of  the timestamp  of  processed  nodes in  the  same  directory (via  `-newer`,
`-anewer`, or `-cnewer`).

###
### Unix epoch

1970-01-01 00:00:00 UTC

Internally, Linux represents any given time as a count of seconds since the Unix
epoch.  You can retrieve the date with:

    $ date --date='@0' --utc --rfc-3339=seconds
    1970-01-01 00:00:00+00:00

###
## transitional package (aka dummy package)

When  a  Debian  package needs  a  new  name,  the  old  package is  kept  as  a
transitional package.  That  is a mostly empty package, which  just installs the
mandatory files in  `/usr/share/doc/<package>/`.  Its purpose is to  pull in the
package with the new name as a dependency.

##
# u
## user mode

Mode in  which the user  processes run.   In this mode,  they can only  access a
subset of memory and CPU operations considered to be safe.

## user space

Memory area where user processes and some drivers execute.
