vim9script

export def Main(lnum1: number, lnum2: number)
    var lines: list<string> = getline(lnum1, lnum2)
    if lines->len() < 3
        # https://paste.debian.net/  doesn't seem  to accept  a paste  shorter
        # than 3 lines
        echomsg 'Share: need at least 3 lines'
        return
    endif

    #    > you can paste to termbin.com from terminal with redirections:
    #    > try 'nc termbin.com 9999 < /path/to/file', or 'command | nc termbin.com 9999'
    #
    # Source: https://ircbots.debian.net/factoids/factoid.php?key=termbin
    # Alternative using `pastebinit(1)`:{{{
    #
    #     silent var url: string = 'pastebinit -a anonymous -b https://paste.debian.net'
    #         ->systemlist(lines)
    #         ->get(-1, '')
    # `-P`: private; create a non-public paste (the URL contains with `/private/`)
    # `-a`: author; default is `$USER`
    #}}}
    silent var url: string = 'nc termbin.com 9999'
        ->systemlist(lines)
        ->get(0, '')
    echomsg url
    silent system('xdg-open ' .. shellescape(url))
enddef
