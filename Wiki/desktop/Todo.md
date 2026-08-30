# progressively switch to a simpler desktop environment

There would be several benefits:

   - fewer bugs
   - less memory/cpu consumption
   - more responsive applications
   - better latency in the terminal (?)
   - easier to understand how the system works (because fewer processes), making issues easier to fix

## small system base

When downloading a Linux ISO, no need for any DE.
For example, for Ubuntu, download the Server Edition:
<https://releases.ubuntu.com/22.04/ubuntu-22.04-live-server-amd64.iso>

## no display manager (aka login manager)

We don't need one:

- <https://github.com/swaywm/sway/wiki#login-managers>
- <https://wiki.gentoo.org/wiki/X_without_Display_Manager>
- <https://askubuntu.com/questions/882422/how-can-i-disable-all-display-managers>
- <https://askubuntu.com/questions/16371/how-do-i-disable-x-at-boot-time-so-that-the-system-boots-in-text-mode/79682#79682>
- <https://superuser.com/questions/974797/how-to-boot-a-linux-system-without-graphical-server>

---

Which file(s) should we use?

According to  the gentoo wiki,  we can  use `~/.xinitrc` and  `~/.bash_login` to
autostart a window manager depending on the virtual console.

    # ~/.xinitrc
    case $(tty | cut -b9-) in
      1) exec startxfce4      ;;
      2) exec openbox-session ;;
    esac

    # ~/.bash_login
    # Auto startx depending on the virtual console
    if [[ -z "$DISPLAY" && $(id -u) -ge 1000 ]] ; then
        TTY=$(tty)
        [[ "${TTY/tty}" != "$TTY" && "${TTY:8:1}" = "3" ]] &&
            startx 1>~/.log/xsession-errors 2>&1 &
        unset TTY
    fi

What's the difference between the two snippets?
Is there a difference between the tty and the virtual console?
What are the pros and cons of using the `exec(1)` command?

If you use them,  the login shell will immediately be replaced  by an X session,
and when you'll quit the latter, you won't get back to the shell.
Con: IOW, you'll have to log in again.
Pro: This should simplify  the output of `pstree(1)` (and maybe  reduce the risk
of issues, because one less process?).
Edit: I  made some  tests in  a VM.   I can't  see much  of a  difference betwen
`exec(1)` and no `exec(1)`.  If you use `exec(1)`, here's the tree of process as
reported by `$ pstree --long --show-parents --show-pids $$`:

    systemd
    login
    bash
    startx
    xinit
    openbox
    xfce4-terminal
    bash

If  you look  at `$ pstree --long --show-parents --show-pids $(pidof -s xinit)`,
you'll see  that, in  addition to  openbox, xinit also  starts the  Xorg server.
Also, if  you don't use  `exec(1)`, then  there's an additional  `sh(1)` process
just after xinit:

    systemd
    login
    bash
    startx
    xinit
    sh               <<<
    openbox
    xfce4-terminal
    bash

I think that `exec(1)` replaces `sh(1)` with the window manager.
Without `exec(1)`, `sh(1)` stays there.

---

Then, we should use `/etc/systemd/system/x11.service` to implement the autologin:

    [Unit]
    After=systemd-user-sessions.service

    [Service]
    ExecStart=/sbin/mingetty --autologin toto --noclear tty8 38400

    [Install]
    WantedBy=multi-user.target

Then, run:

    $ systemctl enable x11.service

To continue...

However, I'm concerned about this file `/etc/systemd/system/display-manager.service`.
Run this:

    $ vim -q <(grepc 'display[-. \n]*manager' ~/Wiki) +cwindow

Are there configurations which we performed on lightdm, and that we should adapt
to our whatever  new window manager we  end up using?  Anyway,  adapt your notes
whenever possible.

## window manager

Try to find a window manager working on Wayland.
Possibly sway which has the benefit of being a *tiling* window manager:
<https://github.com/swaywm/sway>

---

Don't use awesome WM.
Its documentation is way too bad for a beginner, and doesn't support Wayland.

## status bar

Find sth equivalent to polybar for Wayland:
<https://github.com/polybar/polybar>

Waybar maybe:
<https://github.com/Alexays/Waybar>
Or Swaybar:
<https://github.com/swaywm/sway/wiki#swaybar-configuration>

## turn on the Numlock key when the session starts

If using sway:
<https://wiki.archlinux.org/title/Sway#Initially_enable_CapsLock/NumLock>

---

If using X11, I think we need to install the numlockx package, then run this:

    $ numlockx on &
               │  │
               │  └ probably useless, because the process quits immediately (once its job is done)
               └ probably useless, because that's the default action, but it's more explicit that way

This requires the numlockx package.

Where to write the command?  In `~/.profile`?

## find a replacement for the most useful programs installed by a full-blown desktop environment

Like a screen locker, an app to access  system settings, a panel bar, ... Have a
look  at the  output  of `top(1)`,  and  see what  seems  interesting in  what's
running.

Assuming you use sway, you'll probably need a replacement for redshift:
<https://github.com/swaywm/sway/wiki#redshift-equivalent>

For an image viewer like `feh(1)`:
<https://github.com/swaywm/sway/wiki#wallpapers>

To take screenshots:
<https://github.com/swaywm/sway/wiki#taking-screenshots>

For a program launcher:
- <https://github.com/swaywm/sway/wiki#program-launchers>
- <https://github.com/Cloudef/bemenu>

For `$ xset r rate ...`:
<https://github.com/swaywm/sway/wiki#keyboard-repeat-delay-and-rate>

#
# learn how to reduce latency, and how to better judge terminal

- <https://anarc.at/blog/2018-05-04-terminal-emulators-2/#latency> (read the first part too)
- <https://lwn.net/Articles/751763/> (read the first part too)
- <https://pavelfatin.com/typing-with-pleasure/>
- <https://pavelfatin.com/typometer/>
- <https://github.com/pavelfatin/typometer/issues/2>

Also, maybe we should disable UltiSnips' autotrigger even in Vim.
It might not increase the latency, but it might increase the jitter.

---

Note that you can use export the  results of typometer as a file, then re-import
it later.

<https://github.com/pavelfatin/typometer/issues/2#issuecomment-232727288>

   > the  option to  open  a file  is  intended only  for  importing of  previously
   > exported results

---

Does switching to Wayland increase input latency?
If so, do we need some configurations to mitigate the issue?

<https://zamundaaa.github.io/wayland/2021/12/14/about-gaming-on-wayland.html>

# test the twm window manager

From `$ apt show twm`:

   > twm is a window manager for the X Window System.
   > It  provides title  bars,  shaped  windows, several  forms  of icon  management,
   > user-defined macro  functions, click-to-type and pointer-driven  keyboard focus,
   > and user-specified key and pointer button bindings.

Log out and log back to choose it.
It's a very lightweight package, so it could be useful when we need to make some
tests on a new machine or in a VM.
BTW, when you do some tests, install xterm in addition to twm:

    $ apt install twm xterm

Now, after running `startx(1)`, you can make Xorg display sth (xterm).
This is all mentioned here: <https://wiki.gentoo.org/wiki/Xorg/Guide#Using_startx>

When you start twm, left-click on the desktop, and maintain the click.
A menu will appear.
Each entry which contains a square icon on its right is the title of a submenu.
You can enter it by moving your mouse over the icon.
