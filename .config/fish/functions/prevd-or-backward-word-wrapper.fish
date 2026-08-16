function prevd-or-backward-word-wrapper
    # On a non-empty command-line, move back one word.
    if test -n "$(commandline --current-buffer)"
        commandline --function backward-word
        return
    end

    # The command-line is empty.

    # If we're  at the  start of  the directory  history, and  `$TMPDIR/test` is
    # missing, prepend these at the start:
    #
    #    - `$TMPDIR`
    #    - `$TMPDIR/test`
    if test -z "$dirprev"
        set -f dir_history $PWD $dirnext
        if ! contains $TMPDIR/test $dir_history
            set --global --prepend dirprev $TMPDIR $TMPDIR/test
        end
    end

    # move backward through directory history
    prevd
    commandline --function repaint
end
