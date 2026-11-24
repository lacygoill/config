# regularly check whether our user authentication keys are still strong enough

This can't be fully scripted; no code can decide whether they still are.  But we
should still receive a reminder every few years to check manually ourselves that
their algorithms (as  well as their bit  sizes) are still strong  enough for the
next few years.

If  one of  our  key  is no  longer  strong enough  (or  not  for long  enough),
proceed  as  if  it had  already  been  compromised;  that  is, remove  it  from
`authorized_keys`, generate a  new key on the  remote client, and add  it to the
file here.

Try to write a systemd timer which sends  us this reminder via a local mail, but
only if  it can find an  `authorized_keys` in a `/home/user/.ssh/`  directory on
the system.

Also, try to  write a script which  outputs the algorithm and bit  size for each
key in *any* `authorized_keys` file found on the system:

    #!/bin/bash -

    while IFS= read -r key; do
      ssh-keygen -l -f <(echo "$key")
    done < "$HOME/.ssh/authorized_keys"

Include its output in the mail.

Note  that the  previous code  is  too naïve.   It  only runs  for the  current
`$HOME`.  It  should run  for an  `authorized_keys` file  found in  *any* user's
`$HOME`.  And the output  should include the path to the file  (or just the user
name);  there  might be  several  users  on the  machine,  each  with their  own
`authorized_keys`.

# find out how to start a new SSH agent from an XFCE session

ATM, it's automatically started by `xfce4-session(1)`:

    systemd---lightdm---lightdm---xfce4-session---ssh-agent
                                  ^-----------------------^

But if we kill it by accident (`$ pkill ssh`), it becomes a zombie (is that a bug?):

    $ ps --format=stat= --pid="$(pgrep --oldest ssh-agent)"
    Zs
    ^

So, we can no longer terminate it, even with `$ kill -9`.

---

We can start a new process manually:

    $ ssh-agent
    SSH_AUTH_SOCK=/tmp/ssh-fmHPFy7i29qI/agent.20023; export SSH_AUTH_SOCK;
    SSH_AGENT_PID=20024; export SSH_AGENT_PID;
    echo Agent pid 20024;

But  for `ssh-add(1)`  to  find it,  we  need to  reset  `SSH_AUTH_SOCK` in  the
environment of all future shells that we start.  How to do that?

I  guess we  could reset  it  into the  environment  of shells  started by  tmux
(`$ tmux [set|update]-environment ...`).  But  there are  other ways to  start a
shell.  If one is started  by `xfce4-popup-whiskermenu(1)`, it's a descendant of
`xfce4-session(1)`:

    systemd---lightdm---lightdm---xfce4-session---xfce4-panel---panel-1-whisker---xterm---bash---...
                                  ^-----------^                                           ^--^

If a shell is started by `xfrun4(1)`, it's a descendant of `xfsettingsd(1)`:

    systemd---xfsettingsd---xfrun4---xterm---bash---...
              ^---------^                    ^--^
              1 such process per logged user

So, you would need to find a way  to reset the variable in the environment of at
least `xfce4-session(1)` and `xfsettingsd(1)`.

Could `dbus-update-activation-environment(1)` help?
We found it by looking for `strings(1)` in the binary file of `xfce4-session(1)`.
What about the `import-environment` subcommand of `systemctl(1)`?

Note that if a shell is started by one  of our XFCE key bindings, it seems to be
re-parented to `systemd(1)`:

    systemd---xterm---bash---...
    ^-----^           ^--^

Don't try to  update `systemd(1)`'s environment.  It's a  *system* process; it's
not meant  to contain  the variables  of a  user.  Anyway,  `SSH_AUTH_SOCK` does
exist in  such a  shell, which  probably means  that it  was inherited  from the
original parent, which must have been related to XFCE (`xfce4-session(1)`?).

---

For now, to get  back a working SSH agent, the only solution  I could find is to
log out of the XFCE session and log back in.

# automatically reload `sshd(8)` whenever we edit its configuration

    $ sudo systemctl reload sshd

Whether we edit it with `$EDITOR`, or overwrite it with `cp(1)`:

    $ sudo cp {~/.config,}/etc/ssh/sshd_config.d/99-local.conf
