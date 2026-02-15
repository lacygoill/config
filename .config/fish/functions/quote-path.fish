function quote-path
    set -f cmdline $(commandline --current-buffer | string collect)
    set -f curpos $(commandline --cursor)
    set -f i $curpos

    set -f j $(math "$i + 1")
    set -f char_under_cursor $(string sub --start=$j --end=$j $cmdline)
    # The file path ends with a quote.
    # We can safely assume that it's already quoted.{{{
    #
    # In theory, the quote might be included in the path, but it virtually never
    # happens.  ATM, we have  no file path containing `"`. We  do have some file
    # paths containing  `'`, but  almost none at  the end.  IOW,  if you  find a
    # quote, it's practically guaranteed to be syntaxic and not semantic.
    #}}}
    if test "$char_under_cursor" = '"' || test "$char_under_cursor" = "'"
        return
    end

    while test "$i" -gt 1
        set -f i $(math "$i - 1")
        set -f char $(string sub --start=$i --length=1 -- $cmdline)

        # In practice,  a file path with  a semantic (!= syntaxic)  backslash is
        # rare.   Finding such  a path  which also  needs to  be quoted  happens
        # virtually never.
        if test "$char" = '\\'
            break
        end

        # In practice,  we never have  any file  path containing a  newline, nor
        # with a whitespace at the start of a path component.
        # We also stop at `=` to support `--option=/path/to/unquoted file`.{{{
        #
        # A file  path containing an equal  sign is not rare.   But in practice,
        # it's  usually  generated  by  an  application and  used  as  a  cache,
        # somewhere below a directory such as:
        #
        #     ~/.config/mpv/scripts/interSubs.disable/urls/
        #     ~/.local/bin/tor-browser_en-US/Browser/TorBrowser/Data/Browser/profile.default/
        #     ~/.local/share/containers/storage/
        #     ~/.mozilla/firefox/*.default-release/
        #
        # It's not  intended to be  read or  edited.  More importantly,  ATM, no
        # such file path needs to be quoted.
        #}}}
        if test "$char" = ' ' || test "$char" = \t || test "$char" = '=' || test "$char" = \n
            set -f j $(math "$i + 1")
            set -f file_path $(string sub --start=$j --end=$curpos -- $cmdline)
            if test -e "$file_path"
                # We found the start of a file path.
                # But that's not necessarily the one we want to quote.{{{
                #
                # There might be a longer one:
                #
                #     $ touch file\ with\ spaces
                #     $ touch spaces
                #     $ vim file with spaces
                #     # press C-q at the end
                #     # expected:
                #         $ vim 'file with spaces'
                #
                # Let's  assume that  – in  practice –  we want  the longest
                # possible path.  So, for now, let's only save the position, and
                # keep iterating.
                #}}}
                set -f start $j
            end
            if test "$char" = '=' || test "$char" = \n
                break
            end
        end
    end

    if ! set --query start
        return
    end

    set -f file_path $(string sub --start=$start --end=$curpos -- $cmdline)
    set -f quoted_file_path $(string escape -- $file_path)
    set -f len $(string length -- $file_path)
    _commandline_replace_before_cursor '.{'$len'}' $quoted_file_path
end
