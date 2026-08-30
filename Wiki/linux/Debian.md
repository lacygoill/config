# Installation
## Why should I install from a netinst CD image rather than a live install image?

The netinst CD is much smaller (around  5 times), and lets you install a minimal
system.  After you've completed the "Load installer components from installation
media" step, the netinst CD image gives you these new steps:

    ...
    Install the base system
    Configure the package manager
    Select and install software
    Install the GRUB loader
    ...

Notice the presence of the "Select and install software".
This step is absent with a live install image.

On Debian 12 installed  with the netinst CD image, when  `tasksel(8)` is run, if
we enable only "Xfce" and "standard system utilities" (which requires to disable
"Gnome" and  "Debian desktop environment"), we  end up with only  1293 packages.
In contrast, a live install image would install 2164 packages.

Besides, the fewer packages, the fewer bugs.
For example, after installing Debian 12 with  a live XFCE install image, when we
start  for the  first time  in a  VM, we  get this  error message  in a  desktop
notification:

    **IBus Notification**
    Keymap changes do not work in Plasma Wayland at present.
    Please use systemsettings5 instead.

Then, when we re-start the system  afterward, 4 launchers have been removed from
the bottom  panel (there are still  4 icons, but they're  identical and generic,
and they don't launch anything).

No such issues when we install a minimum amount of packages with a netinst CD image.

## How much time does it take to install a minimal system?

On my current machine, around 20 minutes.
But that depends on your CPU, download speed, and the software you select.

## In a menu, how to jump to an entry faster than with the arrow keys?

Press  the  alphabetical  key with  which  the  entry  starts.   You can  do  so
repeatedly.

For example, when you're asked for your location/country, if you want to quickly
select "France", press  `f` three times; that will select  "Faroe Islands", then
"Finland", and finally "France".

To jump back to the start of the  menu, press `a` (or `q` if the keyboard layout
is still QWERTY).

###
## Procedure
### Select "Advanced options", then "Expert install"

### Choose language

For the "Language", select "English".

---

For the "Country, territory or area", select "France":

    other
    > Europe
    > France

Don't lie about your  location.  It needs to be correct for the  time zone to be
correctly set to "Europe/Paris" later.

---

For   the   "Country    to   base   default   locale    settings   on",   select
`United States - en_US.UTF-8`.  No need to select any additional locale.

### Configure the keyboard

Select "French".

### Detect and mount installation media

Nothing to do here.

### Load installer components from installation media

Nothing to do here.  No need to enable any component.

After this step, new steps are added.

### Detect network hardware

Nothing to do here.

### Configure the network

For "Auto-configure networking?", answer "Yes".
It's OK for a desktop; maybe not for a server.

---

Accept the default waiting time for link detection (3 seconds).

---

For the host name, accept "debian".

---

For the domain name, type ".home.arpa.".
It's the only reliable name.
See: <https://datatracker.ietf.org/doc/html/rfc8375>

### Set up users and passwords

For "Allow login as root?", answer "No".
It's more secure: it disables the root account, and forces you to use `sudo(8)`.
The  latter consults  a security  policy  before granting  privileges, and  logs
successful commands as well as authentication failures (aka incidents).

As a benefit, you won't have to install the `sudo` package, nor to add your user
to the `sudo` group.

---

For  the   "Full  name  for  the   new  user",  type  whatever   name  you  want
(e.g. `Lacygoill`, `John Doe`, ...). Note that it will be used by an application
that wants to display your full name, and  that it might be read by other people
if that application is used to communicate/collaborate.

---

For the  "Username for your account",  type whatever name you  want (e.g. `lgc`,
`john`, ...).

---

For "a password for the new user", type whatever password you want.

### Configure the clock

For "Set the clock using NTP?", answer "Yes", and accept the default NTP server.

---

For your time zone, select "Europe/Paris".

### Detect disks

Nothing to do here.

### Partition disks

For a "Partitioning method", select "Guided - use entire disk".

---

Select the disk to partition.

---

For the "Paritioning scheme", select "All files in one partition".

---

Select "Finish partitioning and write changes to disk".
Then, answer "Yes" to "Write the changes to disks?".

### Install the base system

For the "Kernel to install", select the metapackage "linux-image-amd64".
Do *not* choose a specific version, like "6.1.0-9-amd64".
See: <https://unix.stackexchange.com/a/162307>

---

For  the "Drivers  to  include  in the  initrd",  select  "generic: include  all
available drivers".

### Configure the package manager

For "Scan extra installation media?", answer "No".

---

For "Use a network mirror?", answer "Yes".

---

For the "Protocol for file downloads", select "https" (more secure than "http").

---

For the "Debian archive mirror country", select "enter information manually".
Then,  accept "deb.debian.org"  for the  "Debian archive  mirror hostname",  and
"/debian/" for the "Debian archive mirror directory".

---

Leave blank the "HTTP proxy information".

---

For "Use non-free firmware?" and "Use non-free software?", answer "Yes".

---

For "Enable source repositories in APT?", answer "No".

---

For "Services  to use", enable  "backported software" (in addition  to "security
updates" and "release updates" which should be enabled by default).

### Select and install software

For "Updates management on this system", select "No automatic updates".

---

For "Participate in the package usage survey?", answer "No".

---

For the  "software to install",  disable everything,  and enable only  "Xfce" as
well as "standard system utilities".

### Install the GRUB boot loader

For "Run os-prober  automatically to detect and boot other  OSes?", answer "Yes"
if you  have another OS  on your computer,  or if you  might install one  in the
future.

---

For "Install the GRUB boot loader to your primary drive?", answer "Yes".

---

Select the "Device for boot loader installation" (typically `/dev/sda`).

### Finish the installation

For "Is the system clock set to UTC", answer "Yes".

This is to avoid issues with time zone or daylight saving time corrections.  But
that might  cause issues  for a  Windows system in  a dual-boot  setup (or  as a
virtual machine).   Such a  system might  keep the hardware  clock in  the local
timescale, applying  time changes when  booting the  machine by trying  to guess
during time changes if  the change has already been applied  or not.  This works
well as long as  the machine only runs Windows.  But if it  can also run another
system (possibly via a virtual machine), there's no way to determine if the time
is correct.

If you  want to run  Windows on  your machine, either  configure it to  keep the
hardware clock  in the UTC timescale,  by setting the following  registry key to
`1` as a DWORD:

    HKLM\SYSTEM\CurrentControlSet\Control\TimeZoneInformation\RealTimeIsUniversal

Or, on Debian, run:

    $ sudo hwclock --localtime --set

To set  the hardware clock to  the local time  (and make sure to  manually check
your clock during daylight saving time changes).

For more info: `man 8 hwclock /DATE-TIME CONFIGURATION/;/LOCAL vs UTC`.

##
## Todo
### Does Secure Boot cause issues for Debian?

If so, we might need to disable it before starting the installation.
But disabling Secure Boot might cause  issues for Windows; for example, it might
prevent Windows 11 Updates from working.

   - <https://wiki.debian.org/SecureBoot>
   - <https://www.debian.org/releases/bookworm/amd64/ch03s06.en.html>

   - <https://wiki.archlinux.org/title/Dual_boot_with_Windows>
   - <https://wiki.debian.org/DualBoot/Windows>
   - <https://ostechnix.com/dual-boot-windows-and-debian/>

   - <https://www.howtogeek.com/56958/htg-explains-how-uefi-will-replace-the-bios/>
   - <https://wiki.debian.org/UEFI>

   - <https://unix.stackexchange.com/a/518378>

---

From the admin handbook (4.2.18. Installing the GRUB Bootloader):

   > Secure Boot is a technology ensuring that you run only software validated by
   > your operating system vendor. To accomplish its work each element of the boot
   > sequences validates the next software component that it will execute. At the
   > deepest level, the UEFI firmware embeds cryptographic keys provided by Microsoft
   > to check the bootloader's signature, ensuring that it is safe to execute. Since
   > getting a binary signed by Microsoft is a lengthy process, Debian decided to not
   > sign GRUB directly. Instead it uses an intermediary bootloader called shim,
   > which almost never needs to change, and whose only role is to check Debian's
   > provided signature on GRUB and execute GRUB. To run Debian on a machine having
   > Secure Boot enabled, the shim-signed package must be installed.
   >
   > Down the stack, GRUB will do a similar check with the kernel, and then the
   > kernel might also check signatures on modules that get loaded. The kernel might
   > also forbid some operations that could alter the integrity of the system.
   >
   > Debian 10 (Buster) was the first release supporting Secure Boot. Before, you had
   > to disable that feature in the system setup screen offered by the BIOS or the
   > UEFI.

Also (8.8.3. Using GRUB with EFI and Secure Boot):

   > If you are using a system with “Secure Boot“ enabled and have installed shim-
   > signed (see sidebar CULTURE Secure Boot and the shim bootloader), you must also
   > install grub-efi-arch-signed. This package is not pulled in automatically, only
   > if the installation of recommended package has been enabled.

Do we need to install `shim-signed` and/or `grub-efi-amd64-signed`?

---

We might need to tick a checkbox in the Intel NUC BIOS:

   > This is because secure boot via Shim in modern Linux distributions is rooted
   > off the Microsoft  3rd Party UEFI Certificate Authority, which  is also what
   > is  used for  signing add-ons  like video  card ROMs. Earlier  laptop models
   > included it  in their DB, but  nowadays the Microsoft requirement  is not to
   > include  it by  default  unless something  onboard  requires it. That's  why
   > booting  Debian  breaks. Still, it's  often  available  as an  off-by-defult
   > checkbox in the BIOS settings.

Source: <https://old.reddit.com/r/debian/comments/146eqwm/debian_secure_boot/jnqiufy/>

---

If you enable Secure Boot, try to do it before starting Debian's installation.
Otherwise, you might need to run a command in Debian:

    $ efibootmgr -c -d /dev/nvme0n1 -p 1 -L debian-shim -l \\EFI\\debian\\shimx64.efi

<https://old.reddit.com/r/debian/comments/146eqwm/debian_secure_boot/jo323uu/>

---

What about virtual machines?
<https://wiki.debian.org/SecureBoot/VirtualMachine>

---

Can we disable/re-enable Secure Boot simply from the BIOS setup?
Or do we need to run something from Debian?
<https://wiki.debian.org/SecureBoot#Disabling.2Fre-enabling_Secure_Boot>

###
### Is a dual boot really worth the trouble?

Maybe just install Debian and let it wipe Windows?

#### cloning

Should we clone Windows  before wiping it, in case we want to  restore it in the
future?  It  seems Clonezilla Live  could do the job.   It should only  copy the
used blocks:

   > Clonezilla saves and restores only used blocks in the hard disk. This increases the clone efficiency.

Source: <https://clonezilla.org/>
To download it: <https://clonezilla.org/downloads.php>
Documentation: <https://clonezilla.org/clonezilla-live.php>

#### recovery drive

Should we create a recovery drive?
<https://support.microsoft.com/en-us/windows/create-a-recovery-drive-abb4691b-5324-6d4a-8766-73fab304c246>

Or maybe an installation media?
<https://support.microsoft.com/en-us/windows/create-installation-media-for-windows-99a58364-8c02-206f-aa6f-40c3b507420d>

#### re-install without clone/recovery drive

Can we re-install Windows without a clone/recovery drive?

   > You can always download Windows  installation files directly from Microsoft,
   > even from  Linux. If your PC  came with Windows 10,  it has an  embedded key
   > that Setup  will detect automatically. Furthermore, activations  on the same
   > hardware will be automatically restored even without a product key.

Source: <https://superuser.com/questions/1246853/can-clonezilla-restore-a-windows-10-image-to-a-completely-empty-drive#comment1829783_1246853>

Do we need to note this "embedded key"?
The procedure described here doesn't work:
<https://www.intel.com/content/www/us/en/support/articles/000059497/intel-nuc.html>
Basically, it says to execute this command in the PowerShell application:

    (Get-WmiObject -query 'select * from SoftwareLicensingService').OA3xOriginalProductKey

But the output is empty.

Anyway, we might not need this key:

   > A  Factory install  may  have the  Product  Key embedded  in  BIOS chip  on
   > motherboard starting in Windows 8  and will reactivate itself after install
   > or Upgrade.  **An embedded key should not need to be provided during install**,
   > but  can  be confirmed  by  ProduKey  which  will  list it  under  OEM-BIOS
   > key.  You can  also retrieve a Retail  Product key with this  tool prior to
   > reinstall if you've  misplaced it's documentation, it will be  the key that
   > is NOT OEM-BIOS or Generic Version Key used for Digital Licenses.

Source: <https://answers.microsoft.com/en-us/windows/forum/all/clean-install-windows-10-11-2023/1c426bdf-79b1-4d42-be93-17378d93e587>

Or maybe we need to install "Intel® Aptio* V UEFI Firmware Integrator Tools for Intel® NUC":
<https://www.intel.com/content/www/us/en/download/19504/intel-aptio-v-uefi-firmware-integrator-tools-for-intel-nuc.html>
It includes `iSetupCfg`;  a CLI tool which  – among other things  – lets you
extract variables from the BIOS within Linux.

#### activation

   > You should just be able to  reinstall windows, login, and it will recognize
   > and activate  automatically. If this doesn't work,  googling massgravel/kms
   > activation is  easier than dealing  with microsoft  support - they  are not
   > competent.

Source: <https://old.reddit.com/r/intel/comments/11uv2y4/saving_windows_11_activation_key_on_a_new_intel/>

We *might* need to activate Windows the first time we start the machine:
<https://support.microsoft.com/en-us/windows/activate-windows-c39005d4-95ee-b91e-b399-2820fda32227>
We *might* also need to "link" your Windows to a Microsoft account.
And creating the  latter probably requires a  phone number (as well  as an email
address)...

Unless we just pirate Windows with massgravel/kms:
<https://github.com/massgravel/Microsoft-Activation-Scripts>

#### Linux partition creation from Windows

If we want a dual boot, we *might*  need to create a separate disk partition for
Linux from Windows.  How to do that?

<https://wiki.archlinux.org/title/Dual_boot_with_Windows#UEFI_systems>

###
### "Force GRUB installation to the EFI removable media path?"

We might get  this question when performing an expert  install of Debian, during
the "Install the GRUB boot loader" step.

Should we answer "Yes"?

We don't get this question in a VM, but we might once we install the system on a
real machine: <https://dev.to/brandonwallace/how-to-install-debian-11-bullseye-expert-mode-minimal-install-10pd>

##
# /etc/apt/sources.list
## Where is the syntax for a package source documented?

`man sources.list /THE DEB AND DEB-SRC TYPES: GENERAL FORMAT/;/format`

##
## What's the third field?

It usually  contains a  distribution codename  (or a  suite name  like `stable`,
`unstable`, `oldstable`, `testing`) which can be followed by some suffix:

   - `"$(lsb_release --codename --short)"`
   - `"$(lsb_release --codename --short)-security"`
   - `"$(lsb_release --codename --short)-updates"`
   - `"$(lsb_release --codename --short)-backports"`

The first one is for the main  package source; it contains *all* packages but is
rarely updated (only once every few months for a stable "point release").

The other ones are partial: they do *not* contain all packages.

`*-security`  is   for  packages   which  provide   fixes  for   known  software
vulnerabilities.  It's updated more often.

`*-updates` is  for updates which  are deemed important  enough to be  pushed to
users before  the next stable point  release.  Typically, it contains  fixes for
critical  bugs which  could  not be  fixed  before release  or  which have  been
introduced by subsequent  updates.  It also contains updates  for packages which
need them to  remain effective (e.g. spam  detection rules for a  spam filter, a
virus database for an anti-virus, archive keys, etc.).

`*-backports` is for packages of some recent software which have been recompiled
for  an older  distribution  (generally  for the  `stable`  suite).  Useful  for
applications  you use  often  and which  lag  too much  behind  upstream as  the
distribution gets dated (updates only address important issues).

### What are the next fields?

In Debian, a package archive is split into 4 components:

   - `main`: comply with the DFSG (Debian Free Software Guidelines)
   - `contrib`: similar to `main`, but requires some software from `non-free` to work
   - `non-free`: does not comply with the DFSG
   - `non-free-firmware`: similar to `non-free`, but limited to firmware

---

In Ubuntu, the components' names and meanings are different:

   - `main`: supported by Canonical, and free
   - `restricted`: supported by Canonical, but not free
   - `universe`: not supported by Canonical, but free
   - `multiverse`: not supported by Canonical, and not free

##
## Why should a non-official package source be added at the end of the file?

To give it less priority.

Indeed, when  the desired version of  a package is available  in several package
sources, the first one listed in the `sources.list` file is used.

##
# priorities
## How does APT use priorities to decide which package should be installed?

Rules by decreasing order of precedence:

   - APT always installs a specific version of a package explicitly requested by
     the user (e.g. `$ sudo apt install <package>=<version>`)

   - APT always installs a package whose priority is strictly bigger than 1000.
     And it never installs a package whose priority is strictly lower than 0.

   - APT never downgrades a package

   - if APT  must choose between 2  packages, it always chooses  the one with
     the highest priority

   - if APT must choose between 2  packages with the same priority, it always
     chooses the one with the highest version

---

APT defines several default priorities:

   - an installed package has a priority of 100

   - a non-installed package has a priority of 500
     (except for some archives whose packages could introduce instabilities;
     e.g. packages in backports have a priority of 100)

   - a package from the target release (defined with `--target-release`) has
     a priority of 990

## How to set the priority of a given package?

Write an entry in a file fragment in `/etc/apt/preferences.d/`.

An entry is composed of 3 lines:

   - `Package:`
   - `Pin:`
   - `Pin-Priority:`

For the syntax of `Pin:`, see:
`man apt_preferences /Determination of Package Version and Distribution Properties`

---

Here is an example entry which sets the priority of the `snapd` package from any
archive to `-1`:

    Package: snapd
    Pin: release a=*
    Pin-Priority: -1

And here, we  set the priority of  any package whose name  starts with `firefox`
and whose origin is `LP-PPA-mozillateam` to `501`:

    Package: firefox*
    Pin: release o=LP-PPA-mozillateam
    Pin-Priority: 501

---

When several entries match a given package, the most specific one wins.
When several generic entries match a given package, the first one wins.

##
## What's an origin?

It  identifies  an entity  (community,  company,  person) which  maintains  some
packages from one or several archives.

The origin of most  packages is `Debian` (or `Ubuntu`).  But it  can also be the
name of a company:

   - `Docker`
   - `Google LLC`
   - `Oracle Corporation`

Or the name of a project (e.g. `Node Source`), or a PPA (e.g. `LP-PPA-git-core`,
`LP-PPA-wireshark-dev-stable`).

### an archive (aka distribution, aka suite)

For  the `Debian`  and `Ubuntu`  origins, an  archive identifies  a distribution
(e.g. `focal`, `bookworm`, `stable`) *and* a type of updates.

The base archive provides *all* packages for  a given origin, but they might not
be updated often.  Its  name is a codename for the  distribution like `focal` or
`bookworm`.  Other archives provide *some* packages, but with specific purposes:

   - `*-security` help your applications remaining secure

   - `*-updates` help your applications remaining useful/effective
     (e.g. database for an antivirus)

   - `*-backports` help your applications remaining featureful

---

For other origins, an archive usually only identifies a distribution.

### a component?

An archive can be split into one or several components.

A  component identifies  a type  of  licensing in  the  case of  Debian, and  of
licensing/support in the case of Ubuntu.

##
# How can APT guarantee that a package has not been tampered with by some threat actor?

Every source in `/etc/apt/sources.list{,.d/}` downloads an `*InRelease`
file in `/var/lib/apt/lists/`, which is signed in-line; the signature
can be verified by a GPG key from `/etc/apt/trusted.gpg{,.d/}` or
`{/etc/apt,/usr/share}/keyrings/`.

An `*InRelease` file contains a listing of `*Packages` files associated to their
SHA256 hash.  In turn, a `*Packages`  file contains a listing of `.deb` packages
associated to their SHA256 hash.

In summary:

   - a trusted GPG key authenticates an `*InRelease` file (via an in-line signature)
   - a SHA256 hash from `*InRelease` authenticates a `*Packages` file
   - a SHA256 hash from `*Packages` authenticates a `.deb` file

For more info: `man 8 apt-secure`.

##
# How does `dpkg(1)` handle a configuration file during a package update?

If  you modified  it since  it was  initially installed,  `dpkg(1)` will  try to
preserve  the  changes.   BTW,  `dpkg(1)`  considers a  removal  as  a  form  of
modification, and thus tries not to re-install a removed file.

However, if the package was upgraded,  `dpkg(1)` asks you which version you wish
to use:

   - the old one with local modifications
   - the new one provided by the package

If you choose to keep  the old version, the new one will be  backed up in a file
with the  `.dpkg-dist` or  `.ucf-dist` suffix,  in the  same directory.   If you
choose the new version, the old one is  backed up in a file with the `.dpkg-old`
or `.ucf-old` suffix.

---

The response to the prompt can be scripted:

   - `--force-confold` keeps the old version of the file
   - `--force-confnew` installs the new version of the file
   - `--force-confdef` respects the default action

`--force-confdef` can be combined with `--force-confold` or `--force-confnew`:

    --force-confdef,confold
    --force-confdef,confnew

This specifies that  the default action should  be respected, but if  it was not
defined, then  keep the  old file  version (`confold`), or  install the  new one
(`confnew`).

These options apply  to `dpkg(1)`, but can  be passed to the  more practical APT
programs (which will relay them to `dpkg(1)`):

    $ sudo apt --option='dpkg::options::=--force-confdef,confold' upgrade

They can also be stored directly in APT's configuration:

    $ tee --append /etc/apt/apt.conf.d/99zz-local <<'EOF'
    dpkg::options {
      "--force-confdef";
      "--force-confold";
    }
    EOF

The benefit  is that they  will also  be used in  a graphical interface  such as
`aptitude(8)`.

---

You can't nest quotes like this:

    $ sudo apt --option='dpkg::options::="--force-confdef,confold"' upgrade
                                         ^                       ^
                                         ✘                       ✘

The inner quotes would not be removed by `dpkg(1)`.
And you *do* need the trailing `::` in the option name:

    $ sudo apt --option='dpkg::options::=--force-confdef,confold' upgrade
                                      ^^

Because `DPkg::Options` is a list option, and you just want to append an item to
its value; not overwrite it.

---

`--force-` is omitted when you combine several options (e.g. `--force-confdef,confold`):

   > things is a comma separated list of things specified below.

Source: `man dpkg /OPTIONS/;/--force-things`:

Also:

    $ dpkg --force-help
    ...
    warn but continue:  --force-<thing>,<thing>,...
    ...

# How does `dpkg(1)` determine which files must be handled as configuration files inside a `.deb` package?

They're listed in the `conffiles` file.

    $ cd /tmp
    $ apt download vim-tiny
    $ ar x *.deb control.tar.xz
    $ tar --extract --file=control.tar.xz --xz ./conffiles
    $ cat conffiles
    /etc/vim/vimrc.tiny

See also `man 5 deb-conffiles`.

##
# Todo

         │ !packaging
    dpkg │ Visit http://mentors.debian.net/intro-maintainers for information on how to package for Debian.  Also ask
         │ me about <nmg> <package basics> <policy> <mentors> and <best practices>. See the #debian-mentors or
         │ #packaging channels on irc.oftc.net.
