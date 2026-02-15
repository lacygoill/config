# Here's what you need to know about `up-or-search`:{{{
#
# It retrieves the previous command from the history as long as you're in search
# mode (`commandline --search-mode` returns `true`).  And you leave that mode as
# soon  as  you  move  the  cursor on  the  command-line.   When  that  happens,
# `up-or-search` searches the  history for a command which  contains whatever is
# currently written  on the  command-line; unless  the buffer  contains multiple
# lines, and the  cursor is not on  the first one; in  that case, `up-or-search`
# moves the cursor on the line above.
#}}}
# In practice, this is too complex.{{{
#
# We want  the same behavior, but  without looking for a  command which contains
# whatever is currently written on the command-line.
#}}}
# Warning: If you change the code, make sure it remains efficient.{{{
#
# For example, do *not* compute the number of commands in `$history`:
#
#     ... $(count $history)
#         ^---------------^
#                 ✘
#
# The  bigger the  history,  the  costlier `count(1)`  is.   This is  especially
# noticeable once  you get a  long enough  history and you  maintain `C-p`/`C-n`
# pressed: a whole CPU core is consumed, and fish lags (i.e. the commands are no
# longer syntax highlighted,  and they keep cycling for a  while after releasing
# the key).
#
# If it becomes slow, get a profile log.
#}}}

function up-or-search-wrapper --argument-names=dir
    # We might call this function with the `down` argument.
    if test -z "$dir"
        set -f dir up
    end
    set -f do_your_job $dir-or-search

    set -f cmdline $(commandline --current-buffer)
    # We've just  pressed `C-p`  for the  first time since  the last  prompt was
    # drawn; look for the previous command in history.
    if test -z "$cmdline"
        $do_your_job
        return
    end

    # We've already pressed `C-p`/`C-n`, and we're still in search mode.
    if commandline --search-mode
        $do_your_job
        # We might  re-call a long multiline  command causing the prompt  to get
        # erased; try to redraw it.
        if test "$(commandline --line)" -gt 1
            commandline --function repaint
        end
        return
    end

    # We're no longer in search mode (i.e. we've moved the cursor).

    # It's convenient  to clear the command-line  if we press `C-p`  at the very
    # start of the latter.  It lets u re-enter search mode more easily.
    set -f curpos $(commandline --cursor)
    if test "$curpos" -eq 0 \
            && test "$dir" = 'up' \
            && test -n "$cmdline"
        commandline --replace ''
        return
    end

    # We're not in search mode, nor on a multiline command.
    # There is nothing we want to do, so bail out.
    if ! set --query cmdline[2]
        return
    end

    # If we try to go beyond the edges of a multiline command, bail out.{{{
    #
    # Otherwise, `{up|down}-or-search` would  look for a command  in the history
    # which contains  whatever is written  on the command-line.  The  more words
    # there are, the  costlier the function is; and it  gets expensive fast.  We
    # don't want that.  Besides, I find this behavior confusing.
    #}}}
    set -f curline $(commandline --line)
    if test "$dir" = 'up' \
            && test "$curline" -eq 1 \
            || test "$dir" = 'down' \
            && test "$curline" -eq "$(count $cmdline)"
        return
    end

    # We're in the middle of a multiline command.
    # Move the cursor to the next/previous line.
    $do_your_job
end
