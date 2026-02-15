function control-j
    if commandline --paging-mode
        # Why no `commandline --function`?{{{
        #
        # `commandline --function`  is only  necessary to execute  special input
        # functions.  The ones listed by `bind --function-names`
        #
        # But `down-or-search` is not a special input function; it's provided as
        # a normal function: `man bind /ADDITIONAL FUNCTIONS/;/down-or-search`
        #}}}
        down-or-search
    else
        # `man bind /SPECIAL INPUT FUNCTIONS/;/^\s*execute`
        commandline --function execute
    end
end
