# /etc/systemd/

Configuration for the suite of daemons and tools provided by systemd.

##
# For systemd running in `--system` mode (in descending order of priority)

There are 3 directories to consider:

   - `/etc` (sysadmin)
   - `/run` (runtime)
   - `/lib` (operating system, system-wide installed packages)

Each of them is appended `/systemd/system`.
`/systemd` is to isolate the systemd configuration from other programs' configurations.
`/system` is for the `--system` mode.

## /etc/systemd/system

Unit files of the sysadmin.

If you need to  modify a unit file, or create a new  one, this is probably where
you should do it.

## /run/systemd/system

Unit files created at runtime.

---

Those directories *probably* serve a similar purpose:

   - `/run/systemd/generator/`
   - `/run/systemd/generator.late/`
   - `/run/systemd/units/`

## /lib/systemd/system

Unit files that come with the OS or any packages that you might install.

Do *not* edit or add a file in this directory.
Your changes could be overwritten whenever the system gets updated.

#
# For systemd running in `--user` mode

There are 3 directories to consider for the current user:

   - `~/.config`
   - `$XDG_RUNTIME_DIR`
   - `~/.local/share`

And 3 directories for all users:

   - `/etc`
   - `/run`
   - `/lib`

Each of them is appended `/systemd/user`.
`/systemd` is to isolate the systemd configuration from other programs' configurations.
`/user` is for the `--user` mode.

## ~/.config/systemd/user/

Unit files of the current user.

## /etc/systemd/user/

System-wide user unit files placed by the system administrator.

## `$XDG_RUNTIME_DIR/systemd/user/`

Unit files created at runtime, for the current user.

## /run/systemd/user/

Unit files created at runtime, for all users.

## `$HOME/.local/share/systemd/user/`

Unit files of  packages that have been  installed by the current  user, in their
home directory.

## /lib/systemd/user/

Unit files of packages installed system-wide, for all users.
