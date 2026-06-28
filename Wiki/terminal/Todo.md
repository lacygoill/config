# To read:

   - <https://spin0r.wordpress.com/2012/12/15/terminally-confused-part-0/>
   - <https://gist.github.com/egmontkob/eb114294efbcd5adb1944c9f3cb5feda>
   - <https://misc.flogisoft.com/bash/tip_colors_and_formatting>
   - <http://catern.com/posts/terminal_quirks.html>
   - <https://www.cons.org/cracauer/sigint.html>

# Finish reading: <https://www.linusakesson.net/programming/tty/>

   [breakdown 1][2]

A user  types at a terminal  (a physical teletype).  This  terminal is connected
through  a  pair  of  wires  to a  UART  (Universal  Asynchronous  Receiver  and
Transmitter) on the computer.  The operating system contains a UART driver which
manages the  physical transmission  of bytes, including  parity checks  and flow
control.  In  a naïve system,  the UART driver  would then deliver  the incoming
bytes directly to some application process.  But such an approach would lack the
following features:

   - line editing
   - session management

Line editing.

Think of it as a primitive kernel-level `sed(1)`.

Most users make mistakes while typing, so a backspace key is often useful.  This
could be implemented by the applications  themselves, but in accordance with the
UNIX design philosophy, applications should be kept as simple as possible.

So as  a convenience, the operating  system provides an editing  buffer and some
rudimentary editing commands  (backspace, erase word, clear line,  …), which are
enabled  by  default inside  the  line  discipline.  Advanced  applications  may
disable these features by putting the line discipline in raw mode instead of the
default cooked mode.

Most interactive applications  (editors, mail user agents,  shells, all programs
relying on curses or readline) run in  raw mode, and handle all the line editing
commands themselves.   The line discipline  also contains options  for character
echoing and automatic conversion between carriage returns and linefeeds.


Session management.

   - The user  probably wants  to run several  programs simultaneously,  and
     interact with them one at a time.

   - If a program goes into an endless loop,  the user may want to kill it or
     suspend it.

   - Programs that are started in the background should be able to execute until
     they try to write to the terminal, at which point they should be suspended.

   - User input should be directed to the foreground program only.

The operating system implements all these features in the TTY driver.

The TTY driver is  a passive object.  It contains some data  and methods, but it
can only do  something when one of its  methods gets called from a  process or a
kernel interrupt handler.  The line discipline is likewise a passive entity.

The combination of a:

   - UART driver
   - line discipline instance
   - TTY driver

may be referred to as a TTY (device).

A  user  process  can affect  the  behaviour  of  any  TTY by  manipulating  the
corresponding device  file under `/dev`.   Write permissions to the  device file
are required, so when a user logs in  on a particular TTY, that user must become
the  owner of  the  device file.   This  is traditionally  done  by the  `login`
program, which runs with root privileges.

Let's move on to a typical desktop  system.  This is how the Linux console works:

   [breakdown 2][3]

The TTY  driver and line discipline  behave just like in  the previous examples,
but there  is no UART or  physical terminal involved anymore.   Instead, a video
terminal (a  complex state machine  including a  frame buffer of  characters and
graphical character attributes)  is emulated in software, and rendered  to a VGA
display.

The  console  subsystem  is  somewhat  rigid.  Things  get  more  flexible  (and
abstract) if we move the terminal emulation into userland.  This is how xterm(1)
and its clones work:

    breakdown 3

To facilitate moving  the terminal emulation into userland,  while still keeping
the TTY  subsystem (session management  and line discipline) intact,  the pseudo
terminal or pty was invented.  And as you may have guessed, things get even more
complicated when you  start running pseudo terminals inside  pseudo terminals, à
la screen(1) or ssh(1).

Now let's take a step back and see how all of this fits into the process model.

# Study: `:lhelpgrep \cterm\%(info\|cap\)`

##
# Make sure you've always used `tput(1)` instead of a raw sequence.

Look for all the places where we wrote a raw sequence in our plugins:

    \%(\\033\|\\e\)[[\]P]

When possible, try to use `tput` instead.

# Try to always use \033, instead of \e.

Easier to grep.  Fewer matches when we have an issue with a terminal capability.

# Make sure that you use a “smart” terminal when you attach a tmux client to a session.

In  tmux, since  we  set `$TERM`  to `tmux-256color`,  all  programs think  that
they're connected to a terminal supporting  256 colors.  In reality, they're run
by the tmux  server, which will pass  their output to the tmux  client, which in
turn will pass it to the local terminal.  If the latter is a “dumb” terminal
supporting only  8 colors, it  will receive  control sequences which  it doesn't
understand.

---

Create a `tmux` function on the local  machine, which checks the identity of the
terminal before starting a tmux client.  It  should serve as a guard and prevent
tmux from being started if the terminal is too dumb.  It could display a warning
message when it fails, because the terminal is dumb.

The function should be able to parse optional arguments.
Take inspiration from `nv()`.

Edit: Maybe we could  send a sequence encoding a color  above `88`, to determine
whether the terminal supports 256 color...

    $ printf '\e]4;%d;?\a' 123 ; if IFS= read -d $'\a' -s -t 0.1; then echo 'color 123 is supported'; else echo 'color 123 is NOT supported'; fi

Source: <https://unix.stackexchange.com/a/23789/289772>

##
# Reference

[1]: https://invisible-island.net/xterm/ctlseqs/ctlseqs.html#h2-Operating-System-Commands
[2]: $MY_WIKI/graph/terminal/breakdown_1.pdf
[3]: $MY_WIKI/graph/terminal/breakdown_2.pdf
