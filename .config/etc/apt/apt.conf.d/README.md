# Where to find help about this config file?

General syntax:

   - `man 5 apt.conf`
   - `/usr/share/doc/apt/examples/configure-index`

`APT` options to configure the script `apt.systemd.daily`:

   - `/usr/lib/apt/apt.systemd.daily` (comments at the top)

`Unattended-Upgrade` options to configure the script `unattended-upgrade`:

   - `/usr/share/doc/unattended-upgrades/README.md.gz`
     (require the `unattended-upgrades` package)

See also: `man unattended-upgrade(8)`.

##
# How are automatic updates handled?

Every day, 2 systemd timers are triggered:

    /etc/systemd/system/timers.target.wants/apt-daily{,-upgrade}.timer

They start these services:

    /usr/lib/systemd/system/apt-daily{,-upgrade}.service

Which execute the same script:

    /usr/lib/apt/apt.systemd.daily

But they call it with different arguments (`"update"` and `"install"`).

---

All these files are installed by the `apt` package itself.

## What happens when `apt.systemd.daily` is passed the "update" argument?

If enough days have elapsed since  the last time it executed `$ apt-get update`,
the latter command is re-executed.

This  number of  days  is  controlled by  `APT::Periodic::Update-Package-Lists`,
which  might  be  set  in   the  files  `10periodic`  and  `20auto-upgrades`  in
`/etc/apt/apt.conf.d/`.  The latter are provided resp. by the packages:

   - `apt-config-auto-update` (on  Ubuntu,  also  by  `update-notifier-common`
     which  is  pulled  in  by `update-notifier`)

   - `unattended-upgrades`

## What happens when `apt.systemd.daily` is passed the "install" argument?

If   enough   days   have   elapsed    since   the   last   time   it   executed
`/usr/bin/unattended-upgrade`, the latter binary is re-executed.  That number of
days is controlled by `APT::Periodic::Unattended-Upgrade` which is set in:

    /etc/apt/apt.conf.d/20auto-upgrades

`/usr/bin/unattended-upgrade`   is  responsible   for  installing   the  updated
packages, and  is provided  by the package  `unattended-upgrades`.  If  it's not
available,  `apt.systemd.daily`  does  not  install  any  updates.   If  it  is,
it  does not  necessarily  install  updates immediately;  it  has  to honor  the
`Unattended-Upgrade` options which are set in:

    /etc/apt/apt.conf.d/50unattended-upgrades

For example:

    Unattended-Upgrade::Origins-Pattern {
        "${distro_id}:${distro_codename}";
        "${distro_id}:${distro_codename}-security";
    };
    Unattended-Upgrade::InstallOnShutdown "true";
    Unattended-Upgrade::Update-Days { "Sun"; };

This limits the  installation to packages downloaded from the  main and security
archives, and only when the machine is shutting down on Sundays.

##
# All directives must end with a semicolon.

    Scope::Subscope "SomeValue";
                               ^

    #clear Scope::Subscope;
                          ^

## As well as all items in a list value.

    Scope::Subscope { "SomeItem"; };
                                ^

##
# `Scope::Subscope ...;` is equivalent to `Scope { Subscope ...; };`.

    Scope::Subscope ...;

    ⇔

    Scope {
       Subscope ...;
    };

# `Scope::Subscope:: "value";` is equivalent to `Scope::Subscope { "value"; };`.

In   fact,  that's   how  list   options  are   formatted  in   the  output   of
`$ apt-config dump`:

    $ apt-config dump | grep 'APT::NeverAutoRemove'
    APT::NeverAutoRemove "";
    APT::NeverAutoRemove:: "^firmware-linux.*";
    APT::NeverAutoRemove:: "^linux-firmware$";
    APT::NeverAutoRemove:: "^linux-image-[a-z0-9]*$";
    APT::NeverAutoRemove:: "^linux-image-[a-z0-9]*-[a-z0-9]*$";

##
# To reset the value of a list option/scope, you first need to `#clear` it.

Otherwise, whatever  value you write  would be  appended to the  existing value,
instead of overwriting it.

`#clear` is  a special command  which erases the  specified element and  all its
descendants.  It also needs to end with a semicolon.

It's the only way to delete a list  or a complete scope.  Re-opening a scope (or
using the  syntax with an  appended `::`)  does not override  previously written
entries.

For more info: `man apt.conf /SYNTAX/;/#clear`
