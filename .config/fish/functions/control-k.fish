function control-k
    if commandline --paging-mode
        # `man bind /ADDITIONAL FUNCTIONS/;/up-or-search`
        up-or-search
    else
        # `man bind /SPECIAL INPUT FUNCTIONS/;/^\s*kill-line`
        commandline --function kill-line
    end
end
