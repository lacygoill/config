function _commandline_replace_before_cursor --argument-names=regex rep
    set -f rep $(string escape --style=regex -- $rep)

    # compute command-line before cursor
    set -f before_cursor $(commandline --cut-at-cursor | string collect)
    # Do *not* pipe `string-collect(1)` to `string-replace(1)`.{{{
    #
    #     ✘
    #     commandline --cut-at-cursor \
    #         | string collect \
    #         | string replace ...
    #
    # For  some reason,  `string-replace(1)`  would replace  the  regex on  each
    # *input* line.  We  don't want that.  We  want to replace the  regex at the
    # very end of the single string joined by `string-collect(1)`.
    #
    # Note that `string-replace(1)` might still *output* multiple strings, if it
    # operates on a text which contains  newlines; but for our current function,
    # that's  not  a  big  issue.   If  it  becomes  one,  pipe  its  output  to
    # `string-collect(1)` (again).
    #}}}
    set -f before_cursor $(string replace --regex -- $regex'$' $rep $before_cursor)

    # compute command-line after cursor
    set -f cmdline $(commandline --current-buffer | string collect)
    set -f cursor $(commandline --cursor)
    set -f after_cursor $(string sub --start=$(math "$cursor + 1") -- $cmdline)

    # replace command-line with new contents
    commandline --replace -- $before_cursor
    commandline --append -- $after_cursor

    # position cursor where it should be
    set -f new_pos $(string length -- "$before_cursor")
    #                                 ^              ^
    #                                 necessary for a multiline command
    commandline --cursor -- $new_pos
end
