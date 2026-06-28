function control-l
    if commandline --paging-mode
        # `man bind /SPECIAL INPUT FUNCTIONS/;/forward-char`
        commandline --function forward-char
    else

        # home cursor (i.e. move it to very upper left corner of screen)
        tput home
        # Don't use `clear`.
        # It would also delete the scrollback buffer.  We want to keep it.
        # clear to end of screen{{{
        #
        # `man terminfo /DESCRIPTION/;/Predefined Capabilities/;/ed`
        #}}}
        tput ed

        commandline --function repaint
    end
end
