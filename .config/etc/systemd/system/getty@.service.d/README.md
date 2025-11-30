# Use this directory to run arbitrary commands whenever you log in from a virtual console.

Whenever you try to log in from a console, systemd starts a service instantiated
from the template unit:

    /usr/lib/systemd/system/getty@.service

This can be confirmed by looking at the output of:

    $ systemctl status getty@tty1.service
    Loaded: loaded (/lib/systemd/system/getty@.service ...

This service starts `agetty(8)` to let you login from a virtual console:

    ExecStart=-/sbin/agetty --noclear %I $TERM
               ^----------^

This  directory can  be used  to extend  the configuration  of the  template, by
including `ExecStartPre` directives ("Pre" so that our commands are run *before*
`agetty(8)` ). For example, you can run a command to make the background light:

    $ setterm --background=white --foreground=black --store >$(tty)

Or another to set the NumLock flag:

    $ setleds -D +num <$(tty)

# `%I` is a specifier replaced with a tty (e.g. `tty3`)

In  the general  case, it's  replaced with  the unescaped  instance name  of the
instantiated  service.  See:  `man  systemd.unit  /SPECIFIERS/;/%I`.  Here,  the
instance is a tty.

# Do *not* use shell constructs like a redirection without a shell!

For example, that's wrong:

    ExecStartPre=/usr/bin/setterm --background=white --foreground=black --store >/dev/%I
                                                                                ^------^

A redirection is not supported here.  From `man systemd.service`:

   > redirection using "<", "<<", ">", and  ">>", pipes using "|", running programs
   > in  the background  using "&",  and  other elements  of shell  syntax are  not
   > supported.

Either start a shell:

    ExecStartPre=sh -c '/usr/bin/setterm --background=white --foreground=black --store >/dev/%I'
                 ^-----^                                                                       ^

Or use the `StandardInput`/`StandardOutput` directives:

    ExecStartPre=/usr/bin/setterm --background=white --foreground=black --store
    StandardOutput=file:/dev/%I
    ^-------------------------^

`StandardOutput` looks nicer, is more efficient, and probably more reliable.

##
# How to reset the color scheme?

See `man setvtrgb` and `man 8 setvtrgb`.

---

As  a suggestion,  write your  colors in  `/etc/vtrgb`, then  make your  service
execute `$ setvtrgb /etc/vtrgb`.

You don't need to extend the template unit file `getty@.service`:

   > setvtrgb  sets the console color map in **all virtual terminals** according
   > to custom values specified in a file or standard input.

Instead, just write  a regular unit file wanted by  the `multi-user` target, and
with `Type=oneshot`: <https://superuser.com/a/1185870>

BTW, on Ubuntu 20.04, the `console-setup-linux` package installs
`/usr/lib/systemd/system/setvtrgb.service`, whose definition is:

    [Unit]
    Description=Set console scheme
    DefaultDependencies=no
    After=systemd-user-sessions.service plymouth-quit-wait.service
    Before=system-getty.slice
    ConditionPathExists=/sbin/setvtrgb
    ConditionPathExists=/dev/tty0

    [Service]
    Type=oneshot
    ExecStart=/sbin/setvtrgb /etc/vtrgb
    RemainAfterExit=yes

    [Install]
    WantedBy=sysinit.target

---

Recent versions of `setvtrgb(8)` support hex codes, which are easier to read.

Compare:

    1,222,57,255,0,118,44,204,128,255,0,255,0,255,0,255
    1,56,181,199,111,38,181,204,128,0,255,255,0,0,255,255
    1,43,74,6,184,113,233,204,128,0,0,0,255,255,255,255

Versus:

    #000000
    #AA0000
    #00AA00
    #AA5500
    #0000AA
    #AA00AA
    #00AAAA
    #AAAAAA
    #555555
    #FF5555
    #55FF55
    #FFFF55
    #5555FF
    #FF55FF
    #55FFFF
    #FFFFFF
