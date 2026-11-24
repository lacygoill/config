# xinit

    xinit - X Window System initializer

    $ xinit  [  [  client ] options ... ] [ -- [ server ] [ display ] options ... ]

The xinit program is used to start the X Window System server and a first client
program on  systems that are not  using a display  manager such as xdm(1)  or in
environments that use multiple window systems.
When this first client exits, xinit will kill the X server and then terminate.
(NB. In reality, xinit kills X when there's no client anymore; that is, if you start
2 sessions – xfce4 and openbox – and you kill one but not the other, xinit doesn't kill X).

If no specific client program is given  on the command line, xinit will look for
a file in the user's home directory called  .xinitrc to run as a shell script to
start up client programs.
If no such file exists, xinit will use the following as a default:

    $ xterm  -geometry  +1+1  -n  login  -display  :0

If no specific server program is given  on the command line, xinit will look for
a file in the  user's home directory called .xserverrc to run  as a shell script
to start up the server.
If no such file exists, xinit will use the following as a default:

    X  :0

Note that  this assumes that there  is a program  named X in the  current search
path.
The site administrator should, therefore, make a link to the appropriate type of
server  on the  machine, or  create  a shell  script  that runs  xinit with  the
appropriate server.

Note, when using a .xserverrc script be sure to ``exec'' the real X server.
Failing to do this can make the X server slow to start and exit.
For example:

    exec Xdisplaytype

An important point is  that programs which are run by .xinitrc  should be run in
the background if they do not exit  right away, so that they don't prevent other
programs from starting up.
However,  the  last longlived  program  started  (usually  a window  manager  or
terminal emulator)  should be left  in the foreground  so that the  script won't
exit (which indicates that the user is done and that xinit should exit).

An alternate client and/or server may be specified on the command line.
The  desired client  program and  its  arguments should  be given  as the  first
command line arguments to xinit.
To specify a  particular server command line,  append a double dash  (--) to the
xinit command  line (after  any client  and arguments)  followed by  the desired
server command.

Both the client program name and the server program name must begin with a slash
(/) or a period (.).
Otherwise, they are  treated as an arguments to be  appended to their respective
startup lines.
This makes it possible to add  arguments (for example, foreground and background
colors) without having to retype the whole command line.

If an  explicit server name  is not given and  the first argument  following the
double dash (--) is  a colon followed by a digit, xinit will  use that number as
the display number instead of zero.
All remaining arguments are appended to the server command line.

---

Examples

Below are several examples of how command line arguments in xinit are used.

    $ xinit

This will start up  a server named X and run the user's  .xinitrc, if it exists,
or else start an xterm.

    $ xinit -- /usr/bin/Xvnc  :1

This is how one could start a specific type of server on an alternate display.

    $ xinit -geometry =80x65+10+10 -fn 8x13 -j -fg white -bg navy

This will start up a server named X,  and will append the given arguments to the
default xterm command.
It will ignore .xinitrc.

    $ xinit -e widgets -- ./Xorg -l -c

This will use  the command .Xorg -l -c  to start the server and  will append the
arguments -e widgets to the default xterm command.

    $ xinit /usr/ucb/rsh fasthost cpupig -display ws:1 --  :1 -a 2 -t 5

This will start a server named X on display 1 with the arguments -a 2 -t 5.
It will then start  a remote shell on the machine fasthost in  which it will run
the command cpupig, telling it to display back on the local workstation.

Below is  a sample .xinitrc that  starts a clock, several  terminals, and leaves
the window manager running as the ``last'' application.
Assuming that  the window manager  has been  configured properly, the  user then
chooses the ``Exit'' menu item to shut down X.

    xrdb -load $HOME/.Xresources
    xsetroot -solid gray &
    xclock -g 50x50-0+0 -bw 0 &
    xload -g 50x50-50+0 -bw 0 &
    xterm -g 80x24+0+0 &
    xterm -g 80x24+0-0 &
    twm

Sites that  want to create  a common startup  environment could simply  create a
default .xinitrc that references a site-wide startup file:

    #!/bin/sh
    . /etc/X11/xinit/site.xinitrc

Another approach is  to write a script  that starts xinit with  a specific shell
script.
Such scripts are usually  named x11, xstart, or startx and  are a convenient way
to provide a simple interface for novice users:

    #!/bin/sh
    xinit /etc/X11/xinit/site.xinitrc -- /usr/bin/X -br

---

Environment Variables

    DISPLAY

This  variable gets  set to  the name  of the  display to  which clients  should
connect.

    XINITRC

This variable specifies  an init file containing shell commands  to start up the
initial windows.
By default, .xinitrc in the home directory will be used.

---

Files

    .xinitrc

default client script

    xterm

client to run if .xinitrc does not exist

    .xserverrc

default server script

    X

server to run if .xserverrc does not exist

# startx

    startx - initialize an X session

    $ startx  [  [ client ] options ... ] [ -- [ server ] [ display ] options ... ]

The startx script is a front end to xinit(1) that provides a somewhat nicer user
interface for running a single session of the X Window System.
It is often run with no arguments.

Arguments immediately following the startx command are used to start a client in
the same manner as xinit(1).
The special argument '--' marks the end of client arguments and the beginning of
server options.
It  may be  convenient to  specify server  options with  startx to  change on  a
per-session basis the default color depth,  the server's notion of the number of
dots-per-inch  the display  device presents,  or take  advantage of  a different
server  layout,  as  permitted  by  the Xorg(1)  server  and  specified  in  the
xorg.conf(5) configuration.
Some examples of specifying server arguments follow; consult the manual page for
your X server to determine which arguments are legal.

    $ startx -- -depth 16

    $ startx -- -dpi 100

    $ startx -- -layout Multihead

Note  that in  the Debian  system,  what many  people traditionally  put in  the
.xinitrc  file  should  go  in  .xsession  instead;  this  permits  the  same  X
environment to be presented whether startx, xdm, or xinit is used to start the X
session.
All discussion of the .xinitrc file  in the xinit(1) manual page applies equally
well to .xsession.
Keep in mind  that .xinitrc is used  only by xinit(1) and  completely ignored by
xdm(1).

To determine the client to run, startx first looks for a file called .xinitrc in
the user's home directory.
If that is not found, it uses the file xinitrc in the xinit library directory.
If command line client options are given, they override this behavior and revert
to the xinit(1) behavior.
To determine the server to run, startx  first looks for a file called .xserverrc
in the user's home directory.
If that is not found, it uses the file xserverrc in the xinit library directory.
If command line server options are given, they override this behavior and revert
to the xinit(1) behavior.
Users rarely need to provide a .xserverrc file.
See the xinit(1) manual page for more details on the arguments.

The  system-wide xinitrc  and xserverrc  files are  found in  the /etc/X11/xinit
directory.

---

Environment Variables

    DISPLAY

This  variable gets  set to  the name  of the  display to  which clients  should
connect.
Note that this gets set, not read.

    XAUTHORITY

This variable, if not already defined, gets set to $(HOME)/.Xauthority.
This  is  to prevent  the  X  server, if  not  given  the -auth  argument,  from
automatically setting up insecure host-based authentication for the local host.
See  the Xserver(1)  and Xsecurity(7)  manual pages  for more  information on  X
client/server authentication.

---

Files

    $(HOME)/.xinitrc

Client to run.
Typically a shell script which runs many programs in the background.

    $(HOME)/.xserverrc

Server to run.
The default is X.

    /etc/X11/xinit/xinitrc

Client to run if the user has no .xinitrc file.

    /etc/X11/xinit/xserverrc

Server to run if the user has no .xserverrc file.

##
# How to get the list of
## sessions that can be started (like xfce4, openbox, ...)?

    $ update-alternatives --display x-session-manager

## window managers that can be started (like xfwm4, openbox, ...)?

    $ update-alternatives --display x-window-manager
