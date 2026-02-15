# Why should I always use `disable` before `mask`?

`mask` links a unit file to `/dev/null`, making it impossible to be started.
It prohibits enablement and manual activation of the unit.

But it does not remove existing symlinks under `*.{target,service,...}.wants/`.
If you want to get rid of an enabled unit, you *need* to disable it first.

## Why can't I replace `disable --now` with `mask --now`?

If you haven't disabled the unit first,  `mask --now` can cause the system to be
in a degraded state:

    # on Ubuntu 20.04
    $ sudo systemctl unmask ua-timer.timer
    $ sudo systemctl enable --now ua-timer.timer
    $ sudo systemctl mask --now ua-timer.timer

    # the system is in a degraded state
    $ systemctl status

    $ systemctl list-units --state=failed --no-legend --plain
    ua-timer.timer masked failed failed ua-timer.timer
                          ^-----------^

In contrast, there is no issue with `disable --now`.

BTW,  if you  try to  reproduce the  issue in  a script,  add `sleep 1`  between
`enable --now` and `mask --now`.  Also, `reset-failed` fixes the issue.

#
# Some service fails to start!  Where can I find the best help to make it work?

First, query the systemd journal:

    $ journalctl  --unit=some.service --catalog --pager-end -nall
                                      ^-------^
                                          |
    Augment log lines with explanation texts from the message catalog.
    Do *not* use this when attaching a log in a bug report.

It might be quite long.  To make it  more readable, try to capture the output in
a Vim buffer, and start a new fold on every line matching `^-- Subject: `.
*Our custom `za` mapping does exactly that.*

Inside, look for some  short help text giving a solution, or a  URL to a support
forum/documentation.

If you don't find anything, look for the name of the command which fails.  Then,
find  the name  of the  package  providing the  binary/script implementing  this
command.  Example:

    $ dpkg-query --search /path/to/cmd

Next, query your package manager for the description of this package.  Example:

    $ apt show package

Inside the output, look for a URL  to a website where the project developing the
code for the command is hosted.  This website is probably the best place to find
the information  you need.  If it  includes a bug  tracker, type a query  in its
search  box.  If  it's on  github, sort  the filtered  issues so  that the  most
commented ones are at the top.  The  most commented issues are probably the most
relevant for your issue.

## How to get more info about the cause of the error encountered by the service?

Make it use `syslog(3)` to log its STDERR:

    $ sed -i 's/^StandardError=.*/StandardError=syslog/' \
        "$(systemctl show --property=FragmentPath -- some.service | sed 's/[^=]*=//')"

    $ systemctl daemon-reload
    $ systemctl start some.service

Now, query  the journal again.  This  time, there should be  more information in
this section:

    -- Subject: A start job for unit some.service has begun execution
    ...
    ... cmd[some pid]: error message given by the command itself
                       ^---------------------------------------^

#
# Which pitfall could I encounter by starting a service without systemd?

The started  process would inherit the  environment of the current  shell, which
could prevent it from working as expected.

This is  especially problematic if the  service starts other processes  (e.g. it
could be an application launcher  like `xbindkeys(1)`), because those would also
inherit the same environment.

With systemd, there are fewer surprises, because the environment is not affected
by whatever  shell you're currently  in.  And  it's less crowded;  compare those
numbers obtained in my current environment:

    $ env  | wc --lines
    155

    $ systemctl show-environment | wc --lines
    2

    $ systemctl --user show-environment | wc --lines
    42

So, don't run something like this:

    $ xbindkeys

But this:

    $ systemctl --user start xbindkeys

If  you  really  need to  start  a  service  without  systemd, do  it  from  the
application launcher of  your desktop environment.  You might need  to write the
full path to the invoked binaries and to your home:

    $ /usr/bin/xbindkeys --file /home/user/.config/keyboard/xbindkeys.conf
      ^-------^                 ^--------^

# I can't kill a service!

Maybe its `Restart` property is set with a value like `on-abort`:

    $ systemctl show --property=Restart <service>
    Restart=on-abort
            ^------^

This means that the service is automatically restarted whenever its main process
receives  an unclean  kill signal.   That  is, a  signal which  doesn't let  the
process clean up after itself (e.g. `SIGKILL`).

See `man systemd.service /Table 2`.

Solution: Be nice when killing the service.  Let it clean up after itself.
Make sure to send a signal like `SIGTERM` instead of `SIGKILL`.
