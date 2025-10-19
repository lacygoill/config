function end-of-line-or-buffer
    if test "$(count $(commandline --current-buffer))" -gt 1
        commandline --function end-of-buffer
        return
    end
    # `end-of-line` is more useful on a single-line command.
    # Not only does it  jump at the end of the line, but  it can also complete a
    # suggestion (which `end-of-buffer` can't do).
    commandline --function end-of-line
end
