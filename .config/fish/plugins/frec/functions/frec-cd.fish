function frec-cd
    # We might pass a path to a directory instead of a query:{{{
    #
    #     $ frec-cd Tab
    #     # insert: down
    #     # press: Enter
    #
    #     $ frec-cd /home/lgc/Downloads
    #     # expected: jump to /home/lgc/Downloads
    #     # actual: fzf starts again with "/home/lgc/Downloads" as the query
    #
    # FZF starting twice  is confusing.  Let's try to better  handle this corner
    # case.
    #}}}
    if test -d "$argv"
        cd "$argv"
        return
    end

    # Remember that the query could be multi-part.
    # Example:
    #
    #     $ frec-cd vc vim
    #               ^^ ^^^
    set -f query $argv
    set -f dir $(frec -d -e 'printf %s' $query)

    set -f frec_status $status
    if test "$frec_status" -ne 0
        return $frec_status
    end

    if ! test -d "$dir"
        return 1
    end

    cd "$dir"
end
