function control-h
    # If the command-line is showing pager contents (such as tab completions).{{{
    #
    # `man commandline /DESCRIPTION/;/--paging-mode`
    #}}}
    if commandline --paging-mode
        # Then move one character to the left.{{{
        #
        # `man bind /SPECIAL INPUT FUNCTIONS/;/backward-char`
        #}}}
        commandline --function backward-char
    else
        # Otherwise, delete one character of input to the left of the cursor.{{{
        #
        # `man bind /SPECIAL INPUT FUNCTIONS/;/backward-delete-char`
        #}}}
        commandline --function backward-delete-char
    end
end
