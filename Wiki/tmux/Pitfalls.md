# My `if-shell` and/or `run-shell` tmux command doesn't work!

Remember that tmux runs your shell command via **sh**, not bash:
<https://github.com/tmux/tmux/issues/1603#issuecomment-462955856>

So, do *not* test your command in bash, but in sh.

---

For example, if you need to toggle  the logging of the tmux server, this command
works in bash:

    $ kill -SIGUSR2 $(ps --format=ppid= $$)
            ^^^

But in sh, you need to remove the `SIG` prefix.

<https://unix.stackexchange.com/a/199384/289772>

---

For the same  reason, make sure your  shell command does not  invoke `[[`, which
doesn't exist in sh; instead, use `[` or `test`.

    run '[[ -d $TMPDIR/tmux || mkdir $TMPDIR/tmux ]]'
         ^^                                       ^^
         ✘

    run '[ -d $TMPDIR/tmux || mkdir $TMPDIR/tmux ]'
         ^                                       ^
         ✔

    run 'test -d $TMPDIR/tmux || mkdir $TMPDIR/tmux'
         ^--^
          ✔

## It doesn't help!

Then redirect the standard error of the shell command to a file:

    run-shell 'my buggy command 2>/tmp/debug'
                                ^----------^

And read the error message written in the file to get more information.

##
# `$ tmux -Lx` doesn't read `~/.config/tmux/tmux.conf`!

Make sure you don't have a running tmux server listening to the socket `x`:

    $ ps -e -f | grep '[t]mux -Lx'
    user 6771 ... tmux -Lx -f/dev/null˜
                           ^---------^
                           your custom config can't be read because of this

If there's one, kill it – from inside tmux – with `kill-server`:

    $ tmux kill-server

Don't worry, it won't kill another running tmux server.
It probably targets the current server by inspecting `$TMUX`.

---

This issue can happen, even with no  terminal running a tmux client connected to
this `x` socket.

MRE:

    $ xterm
    $ tmux -Lx -f/dev/null
    Alt-F4
    $ ps -e -f | grep '[t]mux -Lx'
    user ... tmux -Lx -f/dev/null˜

Alt-F4 kills the client, but not the server.
The server keeps running in the background.

In contrast, if you  had pressed `C-d` to kill the current  shell, and there was
no other shell handled by the tmux server, this would have killed the latter.

# I have a pane running Vim.  `#{pane_current_command}` is not replaced by `vim`!

Are you running Vim in a pipeline?

    $ echo text | vim -

If so, then `#{pane_current_command}` is replaced by `bash`.
I doubt it's a bug.

Try to get rid of the pipe.
For example, you could write `text` in a file, then pass this file to Vim.

    $ echo text >file ; vim file

If you can't easily get rid of the pipe, then use another heuristic to detect Vim.
For example, if you know that Vim opens an unnamed buffer, you can use:

    #{C:\[No Name\]}

It should  be replaced by  a number different than  `0` (the screen  line number
where `[No Name]` matches).
You can then use `if -F` to react accordingly:

    if -F '#{C:\[No Name\]}' "display 'Vim is running'" "display 'Vim is NOT running'"

#
# Weird sequences are printed on the screen intermittently!

Something  is  probably sending  escape  sequences  (CSI,  OSC, ...)  which  the
terminal doesn't understand.

It can  happen when  you re-attach to  a running tmux  session from  a different
terminal than the one where you started it.

For example, atm, we have a Vim plugin – vim-term – which sends `CSI 2 SPC q` to
the terminal right before exiting.
And xfce4-terminal, on Ubuntu 16.04, doesn't support this sequence.

Solution: Close the terminal,  and re-attach from another  one which understands
the sequence.

Alternatively,  make sure  to  close  the program  responsible  for sending  the
problematic sequence; then close the terminal,  which will kill the tmux client,
and restart a new one.
Note that  in the case  of vim-term + xfce4-terminal  + Ubuntu 16.04,  you would
also need to make sure you start Vim from a new shell, so that tmux has a chance
to update `$COLORTERM`.
Indeed, vim-term relies on the latter to detect xfce4-terminal.

---

You can  reproduce an example of  this issue by  running `$ printf '\e[ 2q'` in
xfce4-terminal on Ubuntu 16.04, and waiting.
The issue is fixed in more  recent versions of xfce4-terminal; I can't reproduce
on Ubuntu 18.04 in a VM.

# tmux is hanging indefinitely after using a process substitution!

So, you've run sth like:

    $ tmux load-buffer <(echo foobar)

Solution: Use `=()` instead of `<()`.

---

Here's what happens.

The shell opens  a file descriptor it  thinks won't be used and  then passes the
path equivalent of that file descriptor to  the client as an argument, which the
client then passes to the server.

But that  file descriptor might  already be  in use in  the server, so  when the
latter opens the fd,  it gets whatever that is, which might  not be suitable for
reading, so it can block or crash or behaves unexpectedly.

It wouldn't be easy to fix  this issue, without also breaking legitimate devices
like `/dev/null` or blacklisting some paths (which will depend on the platform).

For more info: <https://github.com/tmux/tmux/issues/1755>

Edit: I think it has been fixed by:
<https://github.com/tmux/tmux/commit/c284ebe0ade7cc85ad6c3fe5ce7ed5108119222d>

This commit also lets `source-file` read its stdin:
<https://github.com/tmux/tmux/commit/5134666702ce972390f39e34bed9b60fe566263a>

##
# I've updated 'terminal-overrides' while the tmux server is running.  `$ tmux info` is not updated!

Detach and re-attach your tmux client.

If you have  multiple tmux clients using  the same terminal, you  need to detach
them *all*  before re-attaching  any of  them, because  tmux only  maintains one
description per type of terminal client currently attached to the server.

---

You also need to detach/re-attach if  you've edited the description of the outer
terminal with `tic(1)`.

---

You don't need to detach/re-attach every time you update a server option.
`'terminal-overrides'` is a special case.
It has one *single*  value – like any option – but it's  used to build *several*
descriptions: one per type of terminal client attached to the server.
Those descriptions are only updated when you detach/re-attach.
There's no equivalent of such a mechanism for the other server options.

# I've configured Vim to change the shape of the cursor when I enter insert mode, using a DCS sequence.

    :let &t_SI = "\ePtmux;\e\e[6 q\e\\"
    :let &t_EI = "\ePtmux;\e\e[2 q\e\\"
                  ├─┘
                  └ DCS

## It doesn't work as expected!

The cursor shape is often reset to a block while I'm in insert mode.
And in urxvt,  when I focus another  tmux pane without leaving  insert mode, the
cursor shape is not set back to a block.

Solution: Do *not* use a DCS sequence.

    $ tee --append ~/.vim/vimrc <<'EOF'
    let &t_SI = "\e[6 q"
    let &t_EI = "\e[2 q"
    EOF

And set the `Ss` and `Se` capabilities of the outer terminal.

    $ tmux set -as terminal-overrides ',*:Ss=\E[%p1%d q:Se=\E[2 q'
    $ tmux detach
    $ tmux [-Lsocket] attach

##
# I have a complex format whose expansion is not the one I expected!

To debug the expansion, pass the `-v` flag to `display-message`:

    $ tmux display -pv 'complex format'
                     ^

Example:

    $ tmux display -pv '#{||:#{m:*vim,#{pane_current_command}},#{==:#{pane_current_command},man}}'
                        ^-----------------------------------------------------------------------^
                        should be 1 if, and only if, the command running in the pane is vim or man

# I can't use braces from the shell!

Prepend `if -F 1` to your braces:

    ✘
    $ tmux bind x '{ display test }'
    unknown command:  display test˜

    ✔
    $ tmux bind x 'if -F 1 { display test }'
                   ^-----^

---

Rationale:

The shell doesn't care that `{}` are equivalent to quotes for tmux.
From its point of view, they are just regular characters.
No  matter what  you do,  the  shell will  never  consider them  as quotes  when
invoking `execve()`:

    $ tmux bind x '{display test}'
    →
    execve('tmux', 'bind', 'x', '{display test}')
    →
    :bind x '{display test}'
            ^              ^

Here, the tmux command receives the  subcommand `bind`, as well as the arguments
`x` and  `{display test}`; but  since the last  argument contains a  space, tmux
quotes it.

This seems to be confirmed by the fact that if you remove the space, the command
succeeds:

    $ tmux bind x '{display}'
    →
    execve('tmux', 'bind', 'x', '{display}')
    →
    :bind x {display}
            ^       ^
            this time, tmux did *not* add additional quotes

Anyway, when tmux parses the key binding and finds that the rhs is `'{display test}'`,
it cancels the installation because it realizes that the command you're trying to bind
is `{display test}`.  But this is not a valid tmux command; it's a string.
So tmux complains in the exact same way it would complain if you had run:

    $ tmux bind x '"display test"'
    unknown command: display test˜

---

Note that it  seems you can use the  exact same syntax to install  a key binding
whether from the shell or from a tmux file:

    $ tmux bind x display test
    ⇔
    :bind x display test

    $ tmux bind x 'display test'
    ⇔
    :bind x 'display test'

    $ tmux bind x '"display test"'
    ⇔
    :bind x '"display test"'

---

Also, note that  in the case of a  key binding, instead of using `if  -F 1`, you
could also repeat the command and the lhs:

    $ tmux bind x 'bind x { display test }'
                   ^----^

But `display test` would not be run until you press `x` twice.
Because the first time you press `x`, the key binding would redefine itself:

    x 'bind x { display test }'
    →
    x { display test }

# I'm writing nested formats; I have 3 consecutive `}`.  How to prevent Vim from interpreting them as fold markers?

Use a temporary environment variable.

Example:

    is_vim='#{==:vim,#{pane_current_command}}'
    display -p "#{||:#{==:nano,#{pane_current_command}},${is_vim}}"
    setenv -gu is_vim

Don't forget to use double quotes to  surround the nested formats, to allow tmux
to expand the environment variable.

This also gives the benefit of making the code more readable.

---

Do *not* try to add a space in between the brackets.
It would break the meaning of the formats.
Indeed, any character inside `#{}` is syntaxic, including a space:

    $ tmux display -p '#{==:vim,#{pane_current_command}}'
    1˜

                                                       v
    $ tmux display -p '#{==:vim,#{pane_current_command} }'
    0˜

##
# When I try to combine some color with the bold style, I get a different color!

Don't use a named color, and don't use `colour0`, `colour1`, ..., `colour7` either.

Or use st with this patch:

<https://st.suckless.org/patches/bold-is-not-bright/>

---

In a tmux command, when you refer to a color via its name or via `colour0`, ...,
`colour7`, tmux  encodes one  of the  first 8 colors  in the  256-color palette,
using your terminal `setaf` capability.
This gives `\e[30m`, ..., `\e[37m`.

If  you combine  your color  with the  bold style,  tmux sends  to the  terminal
`\e[30;1m`, ..., `\e[37;1m`.
When receiving such sequences, the terminal interprets `1` as bright, not bold:

    $ printf '\e[30;1m  hello  \e[0m\n'

For more info, see our notes about colors in the terminal wiki.

MRE:

    $ tmux -Lx -f =(tee <<'EOF'
    set -gw window-status-format '#[fg=black,bold]#W'
    EOF
    )

The title of a non-focused window should  be in black, but in practice it's in gray.

# Some options which set colors don't work!

Do you use hex color codes, and does your terminal support true colors?
If the answers are yes and no, then make sure the following line is not run when
tmux is started from your terminal:

    set -as terminal-overrides ',*-256color:Tc'

Setting `Tc` may prevent other settings to work, like these for example:

    set -gw window-style        'bg=#cacaca'
    set -gw window-active-style 'bg=#dbd6d1'

This issue is specific to terminals which don't support true colors.

Alternatively, you could use:

   - `colour123` instead of `#ab1234`
   - a terminal supporting true colors

---

MRE:

     $ tmux -Lx -f =(tee <<'EOF'
     set -as terminal-overrides ',*-256color:Tc'
     set -gw window-style         'bg=#000000'
     set -gw window-active-style  'bg=#ffffff'
     EOF
     )

     C-b " (splitw)
     C-b ; (last-pane)

# I'm setting 'status-right'.  The result is unexpected!

Does the value contain a percent character?

If so, you may need to double it:

    $ tmux set -g status-right "#(awk 'BEGIN { printf(\"%%d\", 123) }')"
                                                        ^^

Indeed,  the   values  of  'status-right'   and  'status-left'  are   passed  to
`strftime(3)`, for which the `%` character has a special meaning.
You  need to  double the  character  so that  it's sent  literally to  `awk(1)`;
otherwise, in  the previous example,  `%d` would be replaced  by the day  of the
month (01, 02, ..., 31).

---

Does the value contain a double quote?

If so, you may need to escape it more than what you thought.

    $ tmux set -g status-right "#(echo a\"b)"
    ''˜

    $ tmux set -g status-right "#(echo a\\\"b)"
    a"b˜

In the first command, when the shell receives `a"b`, the quote is interpreted as
the start of a string which is  never closed; hence why the status line contains
nothing.

Run this in sh:

    $ echo a"b
    >˜

You get the secondary prompt string (`>`  by default), because sh expects you to
type more text and close the string with a second `"`.
